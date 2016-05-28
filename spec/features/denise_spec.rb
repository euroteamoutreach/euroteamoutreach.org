describe "Denise bio page", type: :feature do
  before do
    visit "/denise"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Denise Hutchison")
  end
end
