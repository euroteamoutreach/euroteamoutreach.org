describe "Chepara bio page", type: :feature do
  before do
    visit "/chepara"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "The Chepara Family")
  end
end
