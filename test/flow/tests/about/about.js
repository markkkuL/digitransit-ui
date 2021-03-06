module.exports = {
  tags: ['about'],
  'Open about page': (browser) => {
    browser.url(browser.launch_url);
    const menu = browser.page.mainMenu();
    menu.clickMenuToggle();
    menu.openAbout();

    const aboutPage = browser.page.about();
    aboutPage.verifyPage();
    browser.end();
  },
};
