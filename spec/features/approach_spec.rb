describe "Our Approach page", type: :feature do
  before do
    visit "/approach"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Our Approach")
  end
end
