require 'rails_helper'

RSpec.describe PostsHelper, type: :helper do
  describe "#first_few_sentences" do
    it "returns an empty string for nil content" do
      expect(helper.first_few_sentences(nil)).to eq("")
    end

    it "returns an empty string for empty content" do
      expect(helper.first_few_sentences("")).to eq("")
    end

    it "truncates content to exactly 250 characters" do
      long_text = "a" * 300
      expect(helper.first_few_sentences(long_text).length).to eq(250)
    end

    it "strips markdown headers" do
      markdown = "# Header 1\n## Header 2\nRegular text"
      expect(helper.first_few_sentences(markdown)).to eq("Header 1 Header 2 Regular text")
    end

    it "strips markdown emphasis" do
      markdown = "This is **bold** and *italic* text"
      expect(helper.first_few_sentences(markdown)).to eq("This is bold and italic text")
    end

    it "strips markdown links" do
      markdown = "This is a [link to Google](https://google.com)"
      expect(helper.first_few_sentences(markdown)).to eq("This is a link to Google")
    end

    it "strips markdown images" do
      markdown = "This is an image: ![alt text](image.jpg)"
      expect(helper.first_few_sentences(markdown)).to eq("This is an image: alt text")
    end

    it "strips markdown code blocks" do
      markdown = "This is code:\n```ruby\ndef hello\n  puts 'world'\nend\n```\nEnd"
      expect(helper.first_few_sentences(markdown)).to eq("This is code: End")
    end

    it "preserves inline code markers" do
      markdown = "This is `inline code`"
      expect(helper.first_few_sentences(markdown)).to eq("This is `inline code`")
    end

    it "strips markdown blockquotes" do
      markdown = "This is a quote:\n> Quoted text\nRegular text"
      expect(helper.first_few_sentences(markdown)).to eq("This is a quote: Quoted text Regular text")
    end

    it "strips markdown list items" do
      markdown = "List:\n- Item 1\n- Item 2\n1. Numbered item"
      expect(helper.first_few_sentences(markdown)).to eq("List: Item 1 Item 2 Numbered item")
    end

    it "handles complex markdown" do
      markdown = "# Title\n\nThis is a **bold** paragraph with [a link](http://example.com).\n\n- List item 1\n- *Italic* list item\n\n```code block```"
      expect(helper.first_few_sentences(markdown)).to eq("Title. This is a bold paragraph with a link. List item 1 Italic list item")
    end
  end
end
