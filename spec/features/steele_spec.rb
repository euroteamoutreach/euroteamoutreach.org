describe "Steele bio page", type: :feature do
  before do
    visit "/steele"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "The Steele Family")
  end
end
