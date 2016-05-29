describe "Doctrine page", type: :feature do
  before do
    visit "/doctrine"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Doctrine")
  end
end
