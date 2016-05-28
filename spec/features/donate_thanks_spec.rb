describe "Donate thank you page", type: :feature do
  before do
    visit "/donate/thanks"
  end

  it "displays the correct thank you message" do
    expect(page).to have_selector("p", text: "Your donation has been submitted.")
  end
end
