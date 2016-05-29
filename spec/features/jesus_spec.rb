describe "Meet Jesus page", type: :feature do
  before do
    visit "/jesus"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Meet Jesus")
  end
end
