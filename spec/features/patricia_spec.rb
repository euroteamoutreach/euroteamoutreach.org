describe "Patricia bio page", type: :feature do
  before do
    visit "/patricia"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Patricia Rebsch")
  end
end
