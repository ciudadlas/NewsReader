# NewsReader
An iPhone news reader app

# To do
- Fix subview positioning issues in NewsTile view, especially when the tile is getting re-used
- Address TO DO warnings in the code
- Re-evaluate the news tile re-use code, there may be a more straightforward way to accomplish it
- Re-factor, review comments, and pragma mark properly
- Add unit tests
- Test app in different phone sizes
- Review codebase, check memory leaks, use static analyzer
- Write readme documentation
- QA and fix any bugs
- Consider moving back and forward buttons in web view controller to the navigation bar from the bottom bar
- Show user where in the news scrolling he is at (how many has he scrolled, how many more items there are)
- When user reaches the end of scroll view, automatically loads new items
- Persist user's entered search keywords and show a history (Look into trying http://realm.io/ for this)
- Enable search by category and load a list of categories
- Look into a more fun or more comprehensive API instead of Guardian
- Look into making user be able to choose his news sources (like Pulse app)