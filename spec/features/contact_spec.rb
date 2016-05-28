describe "Contact page", type: :feature do
  before do
    visit "/contact"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Contact")
  end
end
