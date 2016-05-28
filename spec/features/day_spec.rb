describe "Day bio page", type: :feature do
  before do
    visit "/day"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "The Day Family")
  end
end
