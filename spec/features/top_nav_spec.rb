describe "top nav links", type: :feature do
  it "correctly navigates to the Ministries page (still at root)" do
    visit "/"
    within ".navigation" do
      click_link "Ministries"
      expect(current_path).to eq("/")
    end
  end

  it "correctly navigates to the Our Team page" do
    visit "/#ministries"
    within ".navigation" do
      click_link "Our Team"
      expect(current_path).to eq("/team")
    end
  end

  it "correctly navigates to the Meet Jesus page" do
    visit "/team"
    within ".navigation" do
      click_link "Meet Jesus"
      expect(current_path).to eq("/jesus")
    end
  end

  it "correctly navigates to the About page" do
    visit "/jesus"
    within ".navigation" do
      click_link "About"
      expect(current_path).to eq("/about")
    end
  end

  it "correctly navigates to the Donate page" do
    visit "/about"
    within ".navigation" do
      find("a.donate").click
      expect(current_path).to eq("/donate")
    end
  end

  it "correctly navigates to the Home page" do
    visit "/about"
    within ".navigation-wrapper" do
      find("a.logo").click
      expect(current_path).to eq("/")
    end
  end
end
