describe "About page", type: :feature do
  before do
    visit "/about"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "About")
  end
end
