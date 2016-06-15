include CustomHelpers

describe CustomHelpers do
  describe "#full_title" do
    context "when no custom page title is provided" do
      it "provides only the base title" do
        title = nil
        expect(full_title(title)).to eq("Euro Team Outreach - Missionaries serving Christ in Ukraine")
      end
    end

    context "when a custom title is provided" do
      it "displays the custom title and the base title separated by a pipe" do
        title = "Custom"
        expect(full_title(title)).to eq("Custom | Euro Team Outreach - Missionaries serving Christ in Ukraine")
      end
    end
  end

  describe "#home_smart_path" do
    context "when on home page" do
      it "returns '#'" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("index")
        expect(home_smart_path(current_page.path)).to eq("#")
      end
    end

    context "when not on home page" do
      it "returns '/'" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("other-page")
        expect(home_smart_path(current_page.path)).to eq("/")
      end
    end
  end

  describe "#ministries_smart_path" do
    context "when on home page" do
      it "returns the Ministries path without a leading slash" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("index")
        expect(ministries_smart_path(current_page.path)).to eq("#ministries")
      end
    end

    context "when not on home page" do
      it "returns the Ministries path *with* a leading slash" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("other-page")
        expect(ministries_smart_path(current_page.path)).to eq("/#ministries")
      end
    end
  end

  describe "#smart_robots" do
    context "when on 'thanks' page" do
      it "returns 'noindex, nofollow'" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("contact/thanks.html")
        expect(smart_robots(current_page.path)).to eq("noindex, nofollow")
      end
    end

    context "when not on 'thanks' page" do
      it "returns 'index, follow'" do
        current_page = double("Sitemap")
        allow(current_page).to receive(:path).and_return("contact")
        expect(smart_robots(current_page.path)).to eq("index, follow")
      end
    end
  end
end
