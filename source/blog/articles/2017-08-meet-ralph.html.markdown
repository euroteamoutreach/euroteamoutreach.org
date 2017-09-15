---

title: "Meet Ralph"
date: "2017-08-04"
tags:
- ministry
- photos
author: ["Joshua Steele", "joshukraine", "@tw"]
image: "/2017/meet-ralph-1200w.jpg"
image_lg: "/2017/meet-ralph-2000w.jpg"
caption: "Raphaël \"Ralph\" Villeneuve is our tri-lingual summer intern with a heart for missions in Eastern Europe."

---

Over the years, I've corresponded with many young men about ministering in Ukraine. The ones who come here usually do so to participate in our [CMO project][cmo title]. This year, we decided to skip CMO so we could focus on some behind-the-scenes work, but God sent us a young man anyway. His name is Ralph, and I'd like for you to meet him. READMORE

---
{: .hr--bold}

DISCLAIMER: This post is longer than most I write. The technical nature of Ralph's work requires some explanation in order for most readers to understand its true impact. If you have the patience, and you're interested to see how God is using a seventeen-year-old to further His kingdom, I encourage you to read on! If you can't bear the suspense, [click here](#skip-to-conclusion) to jump to the conclusion.

---
{: .hr--bold}

Let's start with an email which I received from Ralph in February...

> Hi Joshua,
>
> My name is Raphaël Villeneuve, and I live in Drummondville, Quebec, Canada. I have first contacted you in spring of 2016. I was planning on going to CMO 2017, but just yesterday my mom noticed the announcement of the cancelling of CMO 2017 on the CMO website. I've been praying and asking God's will about this for about eight months now, so I know this is God's answer and that He plans something else for me this summer.
>
> However, I have a burden for the East European countries, and I want to offer you my help for this summer if you need it. I am ready to go to Ukraine and do whatever you'll ask me. I already have collected some funds for this and my parents and church are willing to support me as they did in prayer in the last months.
>
> Blessings,  
> Raphael

At the time I was hesitant to commit, but I have learned by experience that God often brings blessing and direction in ways we cannot anticipate. I therefore agreed to a Skype call so we could discuss the possibilities.

During the call, I explained that our ministry activities this year would be very different from a typical CMO project. We wouldn't be going to the mountains, camping, or showing films. Instead, much of our current work is focused on computer-related tasks such as translation, page layout, and web development. These are tasks that need to be completed in order for future CMO projects and other ministries to remain effective.

Ralph explained that his desire was to gain experience on the mission field in Eastern Europe. Though only 17 years old, he already had a lot of experience with computers, and he said he would be glad to work with us on our projects. We also discussed the potential for taking language lessons and getting to know Ukrainians in our church here in L'viv.

In the end, the decision was made that Ralph could come. What transpired over the next few months confirmed for me beyond all doubt that Ralph's trip to Ukraine was not only God's direction, it was God's blessing and provision for our ministry.

### Diligence and Initiative

Among the first things that impressed me about Ralph were his diligence and initiative. Even before arriving in Ukraine, he began learning the technologies he would need in order to participate in our ministry. I sent him online tutorials and resources, followed by practice work to make sure he understood the concepts. He completed all the training and, still in Canada, he began doing real work that was benefiting our ministry.

As we sent Ralph new tasks, he progressed so quickly that I began to worry I might run out of work for him before he got to Ukraine!

### A Problem that Needed Solving

In order to properly understand the scope of what Ralph has done, I'd like to briefly explain a potentially serious problem we faced in our ministry – a problem that Ralph is helping to resolve.

The full text of our *Bible First* course is well over 100,000 words in length. We also have translations in progress in four foreign languages: French, Russian, Spanish and a revision of our Ukrainian text. When these translations are added to the English original, that gives us over half a million words to manage!

Now imagine the following scenario. You have a collection of Word documents that contain a total of 500,000 words. (By way of comparison, the [average novel is around 80,000 words][word-count title].) Someone points out a typo, so you open one of the documents, search for the paragraph in question, and make the correction. But while you have the document open, you accidentally delete a word. Or a sentence, or an entire paragraph. How would you know? What if you didn't notice, and that text was lost?

One solution to this problem is a technology known as [version control][vcs title]. In our organization, we use a version control system (VCS) called [Git][git title]. Git allows us to store our text in a repository, and it tracks every single change we make. Git also provides for easy remote backup. In short, once a body of text is placed under version control with Git, it is nearly impossible to lose content through human error.

### The Plain-Text Master

The text of *Bible First* was initially stored in a page-layout program called [Adobe InDesign][indesign title]. This program is great if you want to get your text ready for print, but InDesign wasn't intended to serve as a dedicated VCS.

As you have likely inferred by now, we needed to move the text of *Bible First* into version control as soon as possible. But there was one small problem. Git, like most other version control systems, was designed to track *[plain text][plain-text title]* – that is, text which contains no formatting, only line breaks and spaces. So before we could store our text in Git, we first needed to convert every word into plain text. And we needed to be 100% certain that nothing was lost during the conversion process. Enter Ralph - ETO's new resident plain-text master.

Ralph's first task would be to take every English lesson in the *Bible First* program and convert it into a plain-text format called [Markdown][md title]. From there he would go through the entire lesson, paragraph by paragraph, and ensure that all the content was present and displayed in its proper order. This also involved adding special formatting markers that would indicate which text should be bold or italic, which headings should be primary or secondary, and so on.

[![Comparing Spanish and English versions of Bible First in Vim.](https://d21yo20tm8bmc2.cloudfront.net/2017/vim-markdown-550w.png)](https://d21yo20tm8bmc2.cloudfront.net/2017/vim-markdown-2300w.png)
{: .article-image .article-image--has-caption}
Comparing Spanish and English versions of Bible First in Vim.
{: .caption-text .article-image__caption}

Every step of the way, Ralph would save his work in Git - an operation known as *making a commit* - and upload it to a remote repository. When this process was completed for a given lesson, Ralph would send us a request for review. Once approved, the lesson would be merged into what is called the *master branch* - the main body of the repository where all content is kept.

If that all sounded a bit technical, that's because it is. It's hard. Not only can the work become tedious, but it requires a working knowledge of several technologies. Here are some of the primary technologies Ralph learned from scratch in order to work on this project.

- [Unix command line][cli title] (Think black screen, green glowing text - the domain of hackers)
- [Vim][vim title] (A plain-text editor with a reputation for having a steep learning curve)
- [Git][git title] (A distributed version control system)
- [Markdown][md title] (A lightweight markup language for formatting plain text)

As I write this blog post, my email is pinging me about every 30 minutes with Git notifications. It's Ralph, steadily plowing through more plain-text conversion. As of this writing, all the English lessons have been converted and stored safely in our Git repository. 14 lessons of Russian have also been converted, two lessons in Ukrainian, and 17 lessons in Spanish.

### Working in Five Languages

In addition to his work with plain-text conversion, Ralph has also blessed our team with his linguistic skills. Because the Villeneuve family are from Quebec, Ralph's first language is French. Growing up, he attended an English-speaking school, and as a result he is also fluent in English. Then, several years ago, Ralph's parents took their family to Mexico where they served as missionaries for three years. While there, Ralph gained a thorough knowledge of Spanish.

What this means for us is that, with Ralph on the team, we are able to read and verify the text of *Bible First* in every language into which it is currently being translated! For example, as Ralph works through the Spanish lessons, converting the text into Markdown format, he can also read it and help to check for errors. Our Spanish translator, Maria, recently remarked to me, *"I am very glad that Ralph understands Spanish and has a sharp eye. It gives me peace to know that another pair of Spanish eyes are going through my translation."*

### Preparation for Print

Although plain text is the preferred format for storing the source text of *Bible First*, there is still a need to format each lesson for print. This has already been done in English, but as new translations are completed, each one will need to be laid out for print using Adobe InDesign. This means flowing text and graphics on a page, adding page numbers, the table of contents, footnotes, and so forth.

After Ralph arrived in L'viv, I suggested that he might be interested in learning how to use InDesign. I showed him the work we've done previously, and gave a general demonstration of the workflow. Then, as with the other technologies, I sent him an online tutorial to work through. Soon, he completed all 8 hours of material, and said he was ready to try his hand at laying out some real *Bible First* lessons.

Initially, we worked together formatting one of our Ukrainian lessons until Ralph had the hang of it. Then he continued formatting more lessons on his own.

Now, as new material is completed and placed under version control, Ralph has the skills to complete the cycle by formatting the lessons for print.

[![Laying out pages for Bible First in Ukrainian](https://d21yo20tm8bmc2.cloudfront.net/2017/ralph-computer-550w.jpg)](https://d21yo20tm8bmc2.cloudfront.net/2017/ralph-computer-2000w.jpg)
{: .article-image .article-image--has-caption}
Laying out pages for Bible First in Ukrainian.
{: .caption-text .article-image__caption}

<div class="link-target__container">
	<span class="link-target" id="skip-to-conclusion"></span>
	<h3>Conclusion</h3>
</div>

In a recent email to Kelsie, Ralph's mother, Danièle, made the following observation: *"I miss Ralph, but I'm not sad to have him so far of us this summer, because **he chose to follow God and to trust Him with his life.**"*

The remarkable thing about Ralph is not that he's mastered some tough computer skills, or that he speaks three languages, or even that he decided to come to Ukraine for the summer. Ralph's story stands out because, as his mother put so well, he chose to follow God and to trust Him with his life. Many young people are encouraged to do this by parents and mentors, but few are willing to fully commit their futures to the hand of God.

In contrast, Ralph has demonstrated a tenacity and boldness in his obedience to the Lord that is truly exemplary. Even when given tasks which don't fit the stereotypical missionary persona, Ralph has labored whole-heartedly, knowing that his service is not first to ETO, but to Christ. *"And whatsoever ye do, do it heartily, as to the Lord, and not unto men; Knowing that of the Lord ye shall receive the reward of the inheritance: for ye serve the Lord Christ." (Colossians 3:23-24)*

I'm grateful that I've had the opportunity to meet and work with Ralph. I'm glad my kids got to meet Ralph. He is the kind of young man I can point them to and say, "Look kids, that is what a Godly young person looks like. As you grow up, be like Ralph."

Although I've never met Ralph's parents, Dominic and Danièle, I would like to express my gratefulness to them on behalf of my family and all our team here. What we have seen in their son has provided the clearest of windows into a family that trusts and follows the Lord. What a beautiful reminder that the labors of God-fearing parents bring divine fruit, and that through the little arrows which they raise up, God is able to reach to the very ends of the earth!

Make no mistake: the God who searched the globe to find Abraham, David, Samuel, Gideon, and dozens of others, is still searching today. Young person, He is calling you to serve Him too, and if you obey, He will bless your life and use you in ways that you cannot now begin to imagine. *"For the eyes of the LORD run to and fro throughout the whole earth, to shew himself strong in the behalf of them whose heart is perfect toward him..."  (2 Chronicles 16:9)*

---
{: .hr--bold}

[![Be like Ralph.](https://d21yo20tm8bmc2.cloudfront.net/2017/rope-course-04-550w.jpg)](https://d21yo20tm8bmc2.cloudfront.net/2017/rope-course-04-2000w.jpg)
{: .article-image}

**This is Ralph.  
Ralph is happy because he's chosen to follow God.  
Be like Ralph.**
{: .article-text--centered}

[cli title]: https://en.wikipedia.org/wiki/Command-line_interface "Read more about command line interfaces."
[vim title]: https://en.wikipedia.org/wiki/Vim_(text_editor) "Read more about Vim."
[git title]: https://en.wikipedia.org/wiki/Git "Read more about Git."
[md title]: https://en.wikipedia.org/wiki/Markdown "Read more about Markdown."
[plain-text title]: https://en.wikipedia.org/wiki/Plain_text "Read more about plain text."
[vcs title]: https://en.wikipedia.org/wiki/Version_control "Read more about version control."
[indesign title]: https://en.wikipedia.org/wiki/Adobe_InDesign "Read more about Adobe InDesign."
[word-count title]: http://thewritepractice.com/word-count/ "Read more about word count in novels."
[cmo title]: http://www.cmoproject.org/ "Learn more about Carpathian Mountain Outreach."
