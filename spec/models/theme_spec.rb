require 'rails_helper'

RSpec.describe Theme, type: :model do
  describe "constants" do
    it "has a COLORS array with expected values" do
      expect(Theme::COLORS).to be_an(Array)
      expect(Theme::COLORS.length).to eq(9) # Index 0 is empty, 1-8 have hex colors
      expect(Theme::COLORS[0]).to eq("#")
      expect(Theme::COLORS[1]).to eq("#5FCB71")
      expect(Theme::COLORS[8]).to eq("#6C51A4")
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      theme = build(:theme)
      expect(theme).to be_valid
    end

    it "is not valid without a name" do
      theme = build(:theme, name: nil)
      expect(theme).not_to be_valid
      expect(theme.errors[:name]).to include("can't be blank")
    end

    it "validates presence of enabled" do
      theme = build(:theme, enabled: nil)
      expect(theme).not_to be_valid
      expect(theme.errors[:enabled]).to include("is not included in the list")
    end

    it "validates inclusion of enabled in [true, false]" do
      theme = build(:theme, enabled: nil)
      expect(theme).not_to be_valid
      expect(theme.errors[:enabled]).to include("is not included in the list")
    end

    it "validates inclusion of free in [true, false]" do
      theme = build(:theme, free: nil)
      expect(theme).not_to be_valid
      expect(theme.errors[:free]).to include("is not included in the list")
    end

    it "validates inclusion of color in range 1-8" do
      theme = build(:theme, color: 9)
      expect(theme).not_to be_valid
      expect(theme.errors[:color]).to include("is not included in the list")

      theme = build(:theme, color: 0)
      expect(theme).not_to be_valid
      expect(theme.errors[:color]).to include("is not included in the list")

      theme = build(:theme, color: 1)
      expect(theme).to be_valid

      theme = build(:theme, color: 8)
      expect(theme).to be_valid
    end
  end

  describe "custom validations" do
    describe "#at_least_one_enabled" do
      context "when there is only one enabled theme" do
        before do
          Theme.destroy_all
          @theme = create(:theme, enabled: true)
        end

        it "prevents disabling the last enabled theme" do
          @theme.enabled = false
          expect(@theme).not_to be_valid
          expect(@theme.errors[:enabled]).to include("At least one theme must be enabled")
        end
      end
    end
  end

  describe "callbacks" do
    describe "#ensure_only_one_enabled" do
      it "disables other themes when a theme is enabled" do
        themes = [ create(:theme) ]
        themes += create_list(:theme, 2, :disabled)

        expect(themes.first.reload.enabled).to be true

        themes.last.update(enabled: true)

        expect(themes.first.reload.enabled).to be false
        expect(themes.last.reload.enabled).to be true
      end

      it "does not affect other themes when another attribute is updated" do
        theme1 = create(:theme)
        theme2 = create(:theme, :disabled)

        theme2.update(name: "Updated Name")

        expect(theme1.reload.enabled).to be true
      end
    end
  end

  describe ".enabled" do
    it "returns the enabled theme" do
      Theme.delete_all
      enabled_theme = create(:theme)
      create(:theme, :disabled)

      expect(Theme.enabled).to eq(enabled_theme)
    end

    it "returns nil when no theme is enabled" do
      Theme.destroy_all
      create(:theme, enabled: false)

      expect(Theme.enabled).to be_nil
    end
  end
end
