# == Schema Information
#
# Table name: posts
#
#  id           :string           not null, primary key
#  content      :text
#  filename     :text
#  permalink    :string           not null
#  published_at :datetime         not null
#  title        :text
#  updated_at   :datetime
#  category_id  :integer          not null
#
# Indexes
#
#  index_posts_on_category_id  (category_id)
#
# Foreign Keys
#
#  category_id  (category_id => categories.id)
#
require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      post = build(:post, permalink: "/sample-permalink")
      expect(post).to be_valid
    end

    it "requires a permalink" do
      post = build(:post, title: "How Are you", permalink: nil)
      expect(post).to be_valid
      expect(post.permalink).to eq("/how-are-you")
    end

    describe "permalink_starts_with validation" do
      it "corrects permalink to start with '/'" do
        post = build(:post, permalink: "sample-permalink")
        expect(post).to be_valid
        expect(post.permalink).to eq("/sample-permalink")
      end
    end

    context "title handling" do
      it "allows nil title with default value" do
        post = build(:post, title: nil)
        post.valid?
        expect(post.title).to eq("No Title")
      end

      it "persists default title when created through sync" do
        post = Post.sync_from_file_contents!("added", "published/sample.md", "---\nid: test123\n---\nContent")
        expect(post.title).to eq("No Title")
      end
    end

    context "filename handling" do
      it "stores and retrieves filename" do
        post = create(:post, filename: "published/test-post.md")
        expect(Post.find_by(filename: "published/test-post.md")).to eq(post)
      end

      it "handles filename case sensitivity" do
        post = create(:post, filename: "PUBLISHED/test-post.md")
        expect(Post.find_by(filename: "published/test-post.md")).not_to eq(post)
      end
    end
  end

  describe "associations" do
    it "belongs to a category" do
      association = described_class.reflect_on_association(:category)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe "callbacks" do
    describe "#cleanup_columns" do
      it "trims whitespace from title" do
        post = build(:post, title: "  Sample Title  ", permalink: "/test")
        post.validate
        expect(post.title).to eq("Sample Title")
      end

      it "trims whitespace from content" do
        post = build(:post, content: "  Sample Content  ", permalink: "/test")
        post.validate
        expect(post.content).to eq("Sample Content")
      end

      it "handles nil content" do
        post = build(:post, content: nil, permalink: "/test")
        post.validate
        expect(post.content).to eq("")
      end

      it "handles nil title" do
        post = build(:post, title: nil, permalink: "/test")
        post.validate
        expect(post.title).to eq("No Title")
      end
    end

    describe "#ensure_permalink" do
      it "adds a leading slash if missing" do
        post = build(:post, permalink: "sample-permalink")
        post.validate
        expect(post.permalink).to eq("/sample-permalink")
      end

      it "generates a permalink from title if blank" do
        post = build(:post, permalink: "", title: "Sample Title")
        post.validate
        expect(post.permalink).to eq("/sample-title")
      end

      it "generates a permalink from title if just a slash" do
        post = build(:post, permalink: "/", title: "Sample Title")
        post.validate
        expect(post.permalink).to eq("/sample-title")
      end

      # TODO
      # it "escapes special characters in generated permalink" do
      #   post = build(:post, permalink: "", title: "Special & Chars: 100%")
      #   post.validate
      #   expect(post.permalink).to eq("/special+%26+chars%3A+100%25")
      # end
    end

    describe "#ensure_id" do
      it "generates an ID if not provided" do
        post = build(:post, id: nil, permalink: "/test")
        expect { post.validate }.to change { post.id }.from(nil)
        expect(post.id).to match(/^[a-zA-Z0-9]{3}$/)
      end

      it "does not change existing ID" do
        post = build(:post, id: "xyz", permalink: "/test")
        expect { post.validate }.not_to change { post.id }
        expect(post.id).to eq("xyz")
      end
    end
  end

  describe "instance methods" do
    describe "#path" do
      it "returns permalink and ID joined with a hyphen" do
        post = build_stubbed(:post, id: "abc", permalink: "/sample-permalink")
        expect(post.path).to eq("/sample-permalink-abc")
      end
    end
  end

  describe "class methods" do
    describe ".create_from_file_contents!" do
      let(:valid_yaml) do
        <<~YAML
          ---
          id: xyz
          title: Test Post
          date: 2023-01-01
          ---

          This is the content of the post.
        YAML
      end

      let(:invalid_yaml) do
        <<~YAML
          ---
          title: Incomplete Post
          ---
          This is the content of an incomplete post.
        YAML
      end

      context "with valid file contents" do
        it "creates a new post if ID doesn't exist" do
          allow(Post).to receive(:find_by).with(id: "xyz").and_return(nil)
          category = Category.published_root
          allow(Category).to receive(:prepared_category).and_return(category)

          expect {
            Post.sync_from_file_contents!("added", "published/file.md", valid_yaml)
          }.to change { Post.count }.by(1)
        end

        it "updates an existing post if ID exists" do
          existing_post = create(:post, id: "xyz", title: "Old Title")
          category = Category.published_root
          allow(Category).to receive(:prepared_category).and_return(category)

          expect {
            Post.sync_from_file_contents!("modified", "published/file.md", valid_yaml)
          }.not_to change { Post.count }

          existing_post.reload
          expect(existing_post.title).to eq("Test Post")
        end

        it "extracts content correctly" do
          allow(Post).to receive(:find_by).with(id: "xyz").and_return(nil)
          category = instance_double(Category)
          allow(Category).to receive(:prepared_category).and_return(category)

          allow(Post).to receive(:create!)
          Post.sync_from_file_contents!("added", "path/to/file.md", valid_yaml)

          expect(Post).to have_received(:create!).with(
            hash_including(content: "This is the content of the post.")
          )
        end

        it "stores filename when creating new post" do
          allow(Post).to receive(:find_by).with(id: "xyz").and_return(nil)
          category = Category.published_root
          allow(Category).to receive(:prepared_category).and_return(category)

          Post.sync_from_file_contents!("added", "published/file.md", valid_yaml)
          expect(Post.last.filename).to eq("published/file.md")
        end

        it "updates existing post by 'id'" do
          existing_post = create(:post, id: "xyz")
          Post.sync_from_file_contents!("modified", "published/file.md", valid_yaml)
          existing_post.reload
          expect(existing_post.title).to eq("Test Post")
        end

        it "updates existing post by 'filename'" do
          expect(Post.find_by(id: "xyz")).to be_nil
          create(:post, id: "noneXyz", filename: "published/file1.md")

          Post.sync_from_file_contents!("modified", "published/file1.md", valid_yaml)

          expect(Post.find_by(id: "noneXyz")).to be_nil

          new_post = Post.find_by(id: "xyz")
          expect(new_post.title).to eq("Test Post")
          expect(new_post.filename).to eq("published/file1.md")
        end

        it "create a post if id doesn't exist" do
          Post.sync_from_file_contents!("modified", "published/file2.md", valid_yaml)
          expect(Post.find_by(id: "xyz").title).to eq("Test Post")
          expect(Post.find_by(id: "xyz").filename).to eq("published/file2.md")
        end
      end

      context "with invalid file contents" do
        it "returns nil when 'id' is missing" do
          expect {
            Post.sync_from_file_contents!("added", "published/file.md", invalid_yaml)
          }.not_to change { Post.count }
        end
      end

      context "with filename parameter" do
        let(:file_contents) do
          <<~YAML
            ---
            id: sync_test
            date: 2023-01-01
            ---
            No title content
          YAML
        end

        it "creates post with nil title" do
          post = Post.sync_from_file_contents!("added", "drafts/no-title.md", file_contents)
          expect(post.title).to eq("No Title")
          expect(post.filename).to eq("drafts/no-title.md")
        end

        it "updates existing post matching filename" do
          create(:post, filename: "published/existing.md", title: "Old Title")
          Post.sync_from_file_contents!("modified", "published/existing.md", valid_yaml)
          expect(Post.find_by(filename: "published/existing.md").title).to eq("Test Post")
        end
      end
    end

    describe ".find_by filename" do
      it "finds post case-sensitively" do
        post = create(:post, filename: "PUBLISHED/Test.md")
        found = Post.find_by(filename: "published/test.md")
        expect(found).to be_nil
      end

      it "returns nil for non-existent filename" do
        expect(Post.find_by(filename: "missing.md")).to be_nil
      end
    end
  end

  describe "scopes" do
    it "published scope returns posts from published categories" do
      allow(Category).to receive(:published_ids).and_return([ 1, 3, 4 ])
      scope = Post.published
      expect(scope).to be_a(ActiveRecord::Relation)

      # noinspection RubyResolve
      predicate = scope.where_clause.send(:predicates).first
      expect(predicate).to be_a(Arel::Nodes::HomogeneousIn)
      expect(predicate.values).to eq([ 1, 3, 4 ])
      expect(predicate.attribute.name).to eq("category_id")
    end
  end
end
