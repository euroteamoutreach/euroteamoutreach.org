describe "Donate thank you page", type: :feature do
  before do
    visit "/donate/thanks"
  end

  it "displays the correct thank you message" do
    expect(page).to have_selector("p", text: "Your donation has been submitted.")
  end

  it "displays 'noindex, nofollow' for robots" do
    meta_tag = "meta[name=\"robots\"][content=\"noindex, nofollow\"]"
    expect(page).to have_css(meta_tag, visible: false)
  end
end
