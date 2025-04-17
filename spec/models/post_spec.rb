# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  content      :text
#  filename     :text
#  id2          :string
#  permalink    :string           not null
#  published_at :datetime         not null
#  thumbnail    :string
#  title        :text
#  updated_at   :datetime
#  category_id  :integer          not null
#
# Indexes
#
#  index_posts_on_category_id  (category_id)
#  index_posts_on_id2          (id2) UNIQUE
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

    describe "#id2_format validation" do
      it "allows letters, numbers and underscores" do
        post = build(:post, id2: "abc123_XYZ")
        expect(post).to be_valid
      end

      it "rejects special characters" do
        post = build(:post, id2: "abc!@#")
        expect(post).not_to be_valid
        expect(post.errors[:id2]).to include('is invalid! Only letters, numbers and "_" are valid characters.')
      end

      it "hyphens are replaced with '_'" do
        post = build(:post, id2: "abc-123")
        expect(post).to be_valid
      end

      it "rejects spaces" do
        post = build(:post, id2: "abc 123")
        expect(post).not_to be_valid
        expect(post.errors[:id2]).to include('is invalid! Only letters, numbers and "_" are valid characters.')
      end

      it "allows empty id2 on create (will be generated)" do
        post = build(:post, id2: nil)
        expect(post).to be_valid
      end
    end

    describe "#permalink_starts_with validation" do
      it "corrects permalink to start with '/'" do
        post = build(:post, permalink: "sample-permalink")
        expect(post).to be_valid
        expect(post.permalink).to eq("/sample-permalink")
      end

      it "preserves existing permalink if it starts with '/'" do
        post = build(:post, permalink: "/existing-permalink")
        expect(post).to be_valid
        expect(post.permalink).to eq("/existing-permalink")
      end

      it "handles empty permalink" do
        post = build(:post, permalink: "")
        expect(post).to be_valid
        expect(post.permalink).to start_with("/")
      end

      it "handles whitespace in permalink" do
        post = build(:post, permalink: "  sample-permalink  ")
        expect(post).to be_valid
        expect(post.permalink).to eq("/sample-permalink")
      end

      it "keep the case" do
        post = build(:post, permalink: "  SAMPLE-PermaLinK  ")
        expect(post).to be_valid
        expect(post.permalink).to eq("/SAMPLE-PermaLinK")
      end

      it "removes invalid characters from permalink" do
        post = build(:post, permalink: "/Hello! @World#")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World")
      end

      it "replaces underscores with hyphens in permalink" do
        post = build(:post, permalink: "/Hello_World")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World")
      end

      it "handles multiple underscores in permalink" do
        post = build(:post, permalink: "/Hello_World_Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "preserves valid characters in permalink" do
        post = build(:post, permalink: "/Hello-World-123")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-123")
      end

      it "replaces multiple consecutive hyphens with a single hyphen" do
        post = build(:post, permalink: "/Hello---World--Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "handles multiple consecutive hyphens with spaces and underscores" do
        post = build(:post, permalink: "/Hello---World__Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "removes leading slash before processing" do
        post = build(:post, permalink: "/Hello/World")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World")
      end

      it "preserves valid slashes in permalink" do
        post = build(:post, permalink: "Hello/World/Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "handles multiple consecutive slashes" do
        post = build(:post, permalink: "Hello//World///Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "handles mixed slashes and spaces" do
        post = build(:post, permalink: "Hello / World / Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end

      it "handles mixed slashes and underscores" do
        post = build(:post, permalink: "Hello_/World_/Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
      end
    end

    describe "permalink generation" do
      it "generates permalink from title" do
        post = build(:post, title: "Hello World", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "handles special characters in title" do
        post = build(:post, title: "Hello! @World#", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "handles multiple spaces in title" do
        post = build(:post, title: "Hello    World", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "replaces underscores with hyphens" do
        post = build(:post, title: "Hello_World", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "handles multiple underscores" do
        post = build(:post, title: "Hello_World_Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles mixed spaces and underscores" do
        post = build(:post, title: "Hello World_Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "truncates long permalinks" do
        long_title = "a" * 300
        post = build(:post, title: long_title, permalink: nil)
        expect(post).to be_valid
        expect(post.permalink.length).to be <= 256
      end

      it "replaces multiple consecutive hyphens with a single hyphen" do
        post = build(:post, title: "Hello---World--Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles multiple consecutive hyphens with spaces and underscores" do
        post = build(:post, title: "Hello---World__Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles slashes in title" do
        post = build(:post, title: "Hello/World/Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles multiple consecutive slashes in title" do
        post = build(:post, title: "Hello//World///Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles mixed slashes and spaces in title" do
        post = build(:post, title: "Hello / World / Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles mixed slashes and underscores in title" do
        post = build(:post, title: "Hello_/World_/Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "replaces special characters with hyphens" do
        post = build(:post, title: "Hello!@#World$%^Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles multiple special characters" do
        post = build(:post, title: "Hello!@#$%^&*()World", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "handles mixed special characters and spaces" do
        post = build(:post, title: "Hello! @ World # Test", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world-test")
      end

      it "handles special characters at the beginning and end" do
        post = build(:post, title: "!Hello World!", permalink: nil)
        expect(post).to be_valid
        expect(post.permalink).to eq("/hello-world")
      end

      it "handles special characters in permalink" do
        post = build(:post, permalink: "Hello!@#World$%^Test")
        expect(post).to be_valid
        expect(post.permalink).to eq("/Hello-World-Test")
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
        post = build(:post, title: "  Sample Title  ")
        post.validate
        expect(post.title).to eq("Sample Title")
      end

      it "trims whitespace from content" do
        post = build(:post, content: "  Sample Content  ")
        post.validate
        expect(post.content).to eq("Sample Content")
      end

      it "handles nil content" do
        post = build(:post, content: nil)
        post.validate
        expect(post.content).to eq("")
      end

      it "handles nil title" do
        post = build(:post, title: nil)
        post.validate
        expect(post.title).to eq("No Title")
      end

      it "handles empty title" do
        post = build(:post, title: "")
        post.validate
        expect(post.title).to eq("No Title")
      end

      it "handles title with only whitespace" do
        post = build(:post, title: "   ")
        post.validate
        expect(post.title).to eq("No Title")
      end

      it "replaces hyphens with underscores in ID" do
        post = build(:post, id2: "test-id-123")
        post.validate
        expect(post.id2).to eq("test_id_123")
      end

      it "uses gsub to replace hyphens with underscores in ID" do
        post = build(:post, id2: "test-id-123")
        post.validate
        expect(post.id2).to eq("test_id_123")
      end

      it "preserves ID without hyphens" do
        post = build(:post, id2: "TestId_123")
        post.validate
        expect(post.id2).to eq("TestId_123")
      end

      it "sets empty thumbnail to nil" do
        post = build(:post, thumbnail: "")
        post.validate
        expect(post.thumbnail).to be_nil
      end

      it "sets whitespace-only thumbnail to nil" do
        post = build(:post, thumbnail: "  ")
        post.validate
        expect(post.thumbnail).to be_nil
      end

      it "preserves non-empty thumbnail" do
        post = build(:post, thumbnail: "image.jpg")
        post.validate
        expect(post.thumbnail).to eq("image.jpg")
      end
    end

    describe "#ensure_permalink" do
      it "generates permalink when none is provided" do
        post = build(:post, title: "New Post", permalink: nil)
        post.validate
        expect(post.permalink).to eq("/new-post")
      end

      it "preserves provided permalink" do
        post = build(:post, title: "New Post", permalink: "/custom-permalink")
        post.validate
        expect(post.permalink).to eq("/custom-permalink")
      end

      it "handles nil title when generating permalink" do
        post = build(:post, title: nil, permalink: nil)
        post.validate
        expect(post.permalink).to eq("/no-title")
      end
    end

    describe "#ensure_id" do
      it "generates an ID if not provided" do
        post = build(:post, id2: nil)
        expect { post.validate }.to change { post.id2 }.from(nil)
        expect(post.id2).to match(/^[a-zA-Z0-9]{3}$/)
      end

      it "does not change existing ID" do
        post = build(:post, id2: "xyz")
        expect { post.validate }.not_to change { post.id }
        expect(post.id2).to eq("xyz")
      end
    end

    describe "#ensure_permalink_if_missing" do
      it "sets the permalink to the post ID when permalink is '/' when in creation" do
        post = create(:post, permalink: "/", title: "中文全部会被移除，不会出现在永久链接里")
        expect(post.permalink).to eq("/#{post.id}")
      end

      it "sets the permalink to the post ID when permalink is '/' when updating" do
        post = create(:post, permalink: "/custom-permalink", title: "中文全部会被移除，不会出现在永久链接里")
        post.permalink = "/"
        post.save
        expect(post.permalink).to eq("/#{post.id}")
      end

      it "modify the permalink when it is not '/'" do
        post = create(:post, permalink: "/original-permalink")
        post.permalink = "/new-permalink"
        post.save
        expect(post.permalink).to eq("/new-permalink")
      end
    end
  end

  describe "instance methods" do
    describe "#path" do
      it "returns permalink and ID joined with a hyphen" do
        post = build_stubbed(:post, id2: "abc", permalink: "/sample-permalink")
        expect(post.path).to eq("/sample-permalink-abc")
      end
    end
  end

  describe "class methods" do
    describe ".sync_from_file_contents!" do
      let(:valid_yaml) do
        <<~YAML
          ---
          id: xyz
          title: Test Post
          date: 2023-01-05 15:12:37
          thumbnail: thumbnail1.jpg
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

      let(:invalid_date_yaml) do
        <<~YAML
          ---
          id: xyz
          title: Invalid Date Post
          date: af
          ---
          This is the content of an invalid date post.
        YAML
      end

      context "with valid file contents" do
        it "creates a new post if 'id' doesn't exist" do
          expect {
            Post.sync_from_file_contents!("added", "published/file.md", valid_yaml)
          }.to change { Post.count }.by(1)
          post = Post.find_by(id2: "xyz")
          expect(post.title).to eq("Test Post")
          expect(post.published_at).to eq("2023-01-05 15:12:37".to_datetime)
          expect(post.thumbnail).to eq("thumbnail1.jpg")
          expect(post.content).to eq("This is the content of the post.")
          expect(post.permalink).to eq("/test-post")
        end

        it "updates an existing post if 'id' exists" do
          existing_post = create(:post, id2: "xyz", title: "Old Title", permalink: "/Old-Permalink")

          expect {
            Post.sync_from_file_contents!("modified", "published/file.md", valid_yaml)
          }.not_to change { Post.count }

          existing_post.reload
          expect(existing_post.title).to eq("Test Post")
          expect(existing_post.published_at).to eq("2023-01-05 15:12:37".to_datetime)
          expect(existing_post.thumbnail).to eq("thumbnail1.jpg")
          expect(existing_post.content).to eq("This is the content of the post.")
          expect(existing_post.permalink).to eq("/test-post")
        end

        it "stores filename when creating new post" do
          allow(Post).to receive(:find_by).with(id2: "xyz").and_return(nil)
          category = Category.published_root
          allow(Category).to receive(:prepared_category).and_return(category)

          Post.sync_from_file_contents!("added", "published/file.md", valid_yaml)
          expect(Post.last.filename).to eq("published/file.md")
          expect(Post.last.permalink).to eq("/test-post")
        end

        it "updates existing post by 'id'" do
          existing_post = create(:post, id2: "xyz", permalink: "/Old-Permalink")
          Post.sync_from_file_contents!("modified", "published/file.md", valid_yaml)
          existing_post.reload
          expect(existing_post.title).to eq("Test Post")
          expect(existing_post.permalink).to eq("/test-post")
        end

        it "updates existing post by 'filename'" do
          expect(Post.find_by(id2: "xyz")).to be_nil
          create(:post, id2: "noneXyz", filename: "published/file1.md", permalink: "/Old-Permalink")

          Post.sync_from_file_contents!("modified", "published/file1.md", valid_yaml)

          expect(Post.find_by(id2: "noneXyz")).to be_nil

          new_post = Post.find_by(id2: "xyz")
          expect(new_post.title).to eq("Test Post")
          expect(new_post.filename).to eq("published/file1.md")
          expect(new_post.published_at).to eq("2023-01-05 15:12:37".to_datetime)
          expect(new_post.thumbnail).to eq("thumbnail1.jpg")
          expect(new_post.content).to eq("This is the content of the post.")
          expect(new_post.permalink).to eq("/test-post")
        end

        it "create a post if id doesn't exist" do
          Post.sync_from_file_contents!("modified", "published/file2.md", valid_yaml)
          expect(Post.find_by(id2: "xyz").title).to eq("Test Post")
          expect(Post.find_by(id2: "xyz").filename).to eq("published/file2.md")
          expect(Post.find_by(id2: "xyz").permalink).to eq("/test-post")
        end

        context "status is 'rename'" do
          it "update the 'filename' and category if post exist" do
            existing_post = create(:post, id2: "xyz", filename: "published/old_filename.md", permalink: "/Old-Permalink")
            old_content = existing_post.content

            Post.sync_from_file_contents!("renamed", "drafts/new_filename.md", valid_yaml)

            existing_post.reload
            expect(existing_post.filename).to eq("drafts/new_filename.md")
            expect(existing_post.category).to eq(Category.drafts_root)
            expect(existing_post.content).to eq(old_content)
            expect(existing_post.permalink).to eq("/Old-Permalink")
          end

          it "create a post if post doesn't exist" do
            expect(Post.find_by(id2: "xyz")).to be_nil

            expect {
              Post.sync_from_file_contents!("renamed", "drafts/new_filename.md", valid_yaml)
            }.to change { Post.count }.by(1)

            expect(Post.find_by(id2: "xyz").title).to eq("Test Post")
            expect(Post.find_by(id2: "xyz").permalink).to eq("/test-post")
          end
        end

        context "status is 'rename_and_modified'" do
          it "update post if post exist" do
            existing_post = create(:post, id2: "xyz", filename: "drafts/old_filename.md", permalink: "/old-permalink")
            old_content = existing_post.content

            Post.sync_from_file_contents!("renamed_and_modified", "published/new_filename.md", valid_yaml)

            existing_post.reload
            expect(existing_post.filename).to eq("published/new_filename.md")
            expect(existing_post.category).to eq(Category.published_root)
            expect(existing_post.content).not_to eq(old_content)
            expect(existing_post.content).to eq("This is the content of the post.")
            expect(existing_post.permalink).to eq("/test-post")
          end

          it "create a post if post doesn't exist" do
            expect(Post.find_by(id2: "xyz")).to be_nil

            expect {
              Post.sync_from_file_contents!("renamed_and_modified", "drafts/new_filename.md", valid_yaml)
            }.to change { Post.count }.by(1)

            expect(Post.find_by(id2: "xyz").title).to eq("Test Post")
            expect(Post.find_by(id2: "xyz").permalink).to eq("/test-post")
          end
        end
      end

      context "with invalid file contents" do
        it "returns nil when 'id' is missing" do
          expect {
            Post.sync_from_file_contents!("added", "published/file.md", invalid_yaml)
          }.not_to change { Post.count }
        end

        it "deletes the post by filename if 'modified'" do
          create(:post, filename: "published/file4.md", permalink: "/Old-Permalink")

          expect {
            Post.sync_from_file_contents!("modified", "published/file4.md", invalid_yaml)
          }.to change { Post.count }.by(-1)
        end
      end

      context "with invalid date" do
        it "create a new post" do
          expect {
            Post.sync_from_file_contents!("added", "published/file4.md", invalid_date_yaml)
          }.to change { Post.count }.by(1)
          expect(Post.find_by(id2: "xyz").title).to eq("Invalid Date Post")
          expect(Post.find_by(id2: "xyz").published_at).to be_within(1.minute).of(Time.current)
          expect(Post.find_by(id2: "xyz").permalink).to eq("/invalid-date-post")
        end

        %w[modified added].each do |status|
          it "update a post but not change the published_at when '#{status}'" do
            create(:post, id2: "xyz", published_at: Time.current - 5.days, permalink: "/Old-Permalink")
            expect {
              Post.sync_from_file_contents!(status, "published/file4.md", invalid_date_yaml)
            }.not_to change { Post.count }
            post = Post.find_by(id2: "xyz")
            expect(post.title).to eq("Invalid Date Post")
            expect(post.published_at).to be_within(1.minute).of(Time.current - 5.days)
            expect(post.permalink).to eq("/invalid-date-post")
          end
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
          expect(post.permalink).to eq("/no-title")
        end

        it "updates existing post matching filename" do
          create(:post, filename: "published/existing.md", title: "Old Title", permalink: "/Old-Permalink")
          Post.sync_from_file_contents!("modified", "published/existing.md", valid_yaml)
          expect(Post.find_by(filename: "published/existing.md").title).to eq("Test Post")
          expect(Post.find_by(filename: "published/existing.md").permalink).to eq("/test-post")
        end
      end

      context "ID normalization" do
        let(:hyphenated_id_yaml) do
          <<~YAML
            ---
            id: post-with-hyphens-123
            title: Test Post
            date: 2023-01-05 15:12:37
            ---
            This is the content of the post.
          YAML
        end

        it "normalizes hyphenated IDs to use underscores when creating new posts" do
          expect {
            Post.sync_from_file_contents!("added", "published/hyphenated-id.md", hyphenated_id_yaml)
          }.to change { Post.count }.by(1)

          post = Post.last
          expect(post.id2).to eq("post_with_hyphens_123")
          expect(post.id2).not_to include("-")
          expect(post.permalink).to eq("/test-post")
        end

        it "normalizes hyphenated IDs before looking up existing posts" do
          # First create a post with underscores in ID
          create(:post, id2: "post_with_hyphens_123", title: "Original Post", permalink: "/Original-Post")

          # Then try to update it using a hyphenated ID in the content
          Post.sync_from_file_contents!("modified", "published/hyphenated-id.md", hyphenated_id_yaml)

          # The post should be found and updated
          post = Post.find_by(id2: "post_with_hyphens_123")
          expect(post).to be_present
          expect(post.title).to eq("Test Post")
          expect(post.permalink).to eq("/test-post")
        end
      end

      context "with permalink in metadata" do
        it "uses provided permalink" do
          contents = <<~YAML
            ---
            id: test123
            permalink: /Custom-Permalink
            title: Test Post
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("added", "published/test.md", contents)
          expect(post.permalink).to eq("/Custom-Permalink")
        end

        it "handles permalink without leading slash" do
          contents = <<~YAML
            ---
            id: test123
            permalink: Custom-Permalink
            title: Test Post
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("added", "published/test.md", contents)
          expect(post.permalink).to eq("/Custom-Permalink")
        end

        it "handles special characters in provided permalink" do
          contents = <<~YAML
            ---
            id: test123
            permalink: /Custom!@#Permalink
            title: Test Post
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("added", "published/test.md", contents)
          expect(post.permalink).to eq("/Custom-Permalink")
        end

        it "handles whitespace in provided permalink" do
          contents = <<~YAML
            ---
            id: test123
            permalink: "  Custom Permalink  "
            title: Test Post
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("added", "published/test.md", contents)
          expect(post.permalink).to eq("/Custom-Permalink")
        end
      end

      context "with existing post" do
        let!(:existing_post) do
          create(:post,
            id2: "test123",
            permalink: "/Old-Permalink",
            title: "Old Title",
            filename: "published/test.md"
          )
        end

        it "updates permalink when provided in metadata" do
          contents = <<~YAML
            ---
            id: test123
            permalink: /New-Permalink
            title: New Title
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("modified", "published/test.md", contents)
          expect(post.permalink).to eq("/New-Permalink")
        end

        it "generates new permalink when title changes and no permalink provided" do
          contents = <<~YAML
            ---
            id: test123
            title: New Title
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("modified", "published/test.md", contents)
          expect(post.permalink).to eq("/new-title")
        end
      end

      context "with renamed file" do
        let!(:existing_post) do
          create(:post,
            id2: "test123",
            permalink: "/Old-Permalink",
            title: "Old Title",
            filename: "published/old.md"
          )
        end

        it "preserves permalink when file is renamed" do
          contents = <<~YAML
            ---
            id: test123
            title: New Title
            ---
            Content
          YAML
          post = Post.sync_from_file_contents!("renamed", "published/new.md", contents)
          expect(post.permalink).to eq("/Old-Permalink")
        end
      end
    end

    describe ".find_by filename" do
      it "finds post case-sensitively" do
        create(:post, filename: "PUBLISHED/Test.md")
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
