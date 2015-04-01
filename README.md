# NewsReader
A news reader app for iPhone

# To do
- Address to do warnings in the code
- Re-evaluate the news tile re-use code in `TileScrollViewManager`, there may be a more straightforward way to accomplish it
- Re-factor, review comments, and pragma mark properly
- Add unit tests
- Review codebase, check memory leaks, ~~use static analyzer~~
- Write readme documentation
- QA, test app in different phone sizes and fix any bugs
- Consider moving back and forward buttons in web view controller to the navigation bar from the bottom bar
- Show user where in the news scrolling he is at (how many has he scrolled, how many more items there are)
- When user reaches the end of scroll view, automatically load new items
- Persist user's entered search keywords and show a history (Look into trying http://realm.io/ for this)
- Enable search by category and load a list of categories
- Look into a more fun or more comprehensive API instead of Guardian
  - https://www.petfinder.com/developers/api-docs 
  - https://www.rescuegroups.org/services/adoptable-pet-data-http-json-api/
- Look into making user be able to choose his news sources (like Pulse app)
