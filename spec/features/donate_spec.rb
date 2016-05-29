describe "Donate page", type: :feature do
  before do
    visit "/donate"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Donate")
  end
end
