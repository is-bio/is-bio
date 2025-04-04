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
FactoryBot.define do
  factory :post do
    filename { "published/#{Faker::Lorem.words(number: 3).join('-').downcase}" }
    id { Faker::Lorem.characters(number: 4) }
    title { Faker::Lorem.words(number: 8).join(" ").titleize }
    category_id { Category::ID_PUBLISHED }
    published_at { Time.current }
    permalink { "/#{Faker::Lorem.words(number: 3).join('-').downcase}" }
    content { "# Sample Post\n\nThis is a sample markdown content for testing purposes.\n\n- List item 1\n- List item 2\n\n```ruby\nputs 'Hello world'\n```" }

    trait :published do
      category_id { Category::ID_PUBLISHED }
    end

    trait :drafts do
      category_id { Category::ID_DRAFTS }
    end

    # Not used yet
    trait :with_content do
      content do
        <<~MARKDOWN
          # #{Faker::Lorem.sentence}

          #{Faker::Lorem.paragraph(sentence_count: 3)}

          ## #{Faker::Lorem.sentence}

          #{Faker::Lorem.paragraph(sentence_count: 2)}

          - #{Faker::Lorem.sentence}
          - #{Faker::Lorem.sentence}
          - #{Faker::Lorem.sentence}

          ### Code Sample

          ```ruby
          class Sample
            def hello
              puts "Hello world!"
            end
          end
          ```

          #{Faker::Lorem.paragraph(sentence_count: 3)}
        MARKDOWN
      end
    end
  end
end
