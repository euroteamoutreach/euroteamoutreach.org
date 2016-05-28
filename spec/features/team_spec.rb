describe "Our Team page", type: :feature do
  before do
    visit "/team"
  end

  it "displays the correct heading" do
    expect(page).to have_selector("h1", text: "Our Team")
  end
end
