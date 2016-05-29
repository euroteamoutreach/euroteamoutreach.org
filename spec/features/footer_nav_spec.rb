describe "footer nav links", type: :feature do
  it "correctly navigates to the Ministries page (root)" do
    visit "/about"
    within "footer.universal-footer" do
      click_link "Ministries"
      expect(current_path).to eq("/")
    end
  end

  it "correctly navigates to the Our Team page" do
    visit "/"
    within "footer.universal-footer" do
      click_link "Our Team"
      expect(current_path).to eq("/team")
    end
  end

  it "correctly navigates to the Meet Jesus page" do
    visit "/team"
    within "footer.universal-footer" do
      click_link "Meet Jesus"
      expect(current_path).to eq("/jesus")
    end
  end

  it "correctly navigates to the Meet Jesus page" do
    visit "/"
    within "footer.universal-footer" do
      click_link "introduce you"
      expect(current_path).to eq("/jesus")
    end
  end

  it "correctly navigates to the Doctrine page" do
    visit "/jesus"
    within "footer.universal-footer" do
      click_link "Doctrine"
      expect(current_path).to eq("/doctrine")
    end
  end

  it "correctly navigates to the About page" do
    visit "/doctrine"
    within "footer.universal-footer" do
      click_link "About"
      expect(current_path).to eq("/about")
    end
  end

  it "correctly navigates to the Our Approach page" do
    visit "/about"
    within "footer.universal-footer" do
      click_link "Our Approach"
      expect(current_path).to eq("/approach")
    end
  end

  it "correctly navigates to the Contact page" do
    visit "/approach"
    within "footer.universal-footer" do
      click_link "Contact"
      expect(current_path).to eq("/contact")
    end
  end

  it "correctly navigates to the Donate page" do
    visit "/contact"
    within "footer.universal-footer" do
      click_link "Donate"
      expect(current_path).to eq("/donate")
    end
  end

  it "correctly navigates to the ETO Facebook page" do
    visit "/donate"
    within "footer.copyright-footer" do
      find("a.facebook").click
      expect(current_url).to eq("https://www.facebook.com/euroteamoutreach")
    end
  end

  it "correctly navigates to the ETO Twitter page" do
    visit "/team"
    within "footer.copyright-footer" do
      find("a.twitter").click
      expect(current_url).to eq("https://twitter.com/eto_ukraine")
    end
  end

  it "correctly navigates to the euroteamoutreach.org GitHub page" do
    visit "/doctrine"
    within "footer.copyright-footer" do
      find("a.github").click
      expect(current_url).to eq("https://github.com/joshukraine/euroteamoutreach.org")
    end
  end

  it "correctly navigates to the Mailchimp subscription form " do
    mailchimp_url = "http://euroteamoutreach.us6.list-manage.com/subscribe/post?u=672df31cd6d0e7132c9c4c7d1&amp;id=d107e57061"
    visit "/"
    within ".mc-embed-signup-scroll" do
      click_button "Subscribe"
      expect(current_url).to eq(mailchimp_url)
    end
  end
end
