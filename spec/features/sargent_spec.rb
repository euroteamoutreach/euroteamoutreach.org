describe "Sargent bio page", type: :feature do
  before do
    visit "/sargent"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "The Sargent Family")
  end
end
