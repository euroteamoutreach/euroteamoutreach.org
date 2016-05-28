describe "Beal bio page", type: :feature do
  before do
    visit "/beal"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "The Beal Family")
  end
end
