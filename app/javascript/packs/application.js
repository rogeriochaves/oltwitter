// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

const qs = (x) => document.querySelector(x);

const evaluateScripts = (html) => {
  const scripts = html.matchAll(/<script.*?>([\s\S]+?)<\/script>/gm);
  for (const match of scripts) {
    if (match[1]) eval(match[1]);
  }
};

if (qs(".new-tweet")) {
  let inReplyTo = null;

  qs(".new-tweet").addEventListener("input", (e) => {
    const tweet = e.target.value;

    qs(".character-count").textContent = `${140 - tweet.length}`;

    if (inReplyTo && tweet.indexOf(inReplyTo) < 0) {
      qs("input[name=in_reply_to]").value = "";
      inReplyTo = null;
    }
  });

  window.replyTo = function (tweetId, screenName) {
    qs("input[name=in_reply_to]").value = tweetId;
    qs(".new-tweet").value = `@${screenName} `;
    qs(".new-tweet").focus();
    inReplyTo = screenName;
  };
}

if (qs(".load-more")) {
  qs(".load-more").addEventListener("click", (_) => {
    qs(".load-more").innerText = "loading...";
    fetch(`/_timeline?after=${window.LAST_TWEET_ID}`)
      .then((response) => response.text())
      .then((tweets) => {
        qs(".home-timeline").insertAdjacentHTML("beforeend", tweets);
        evaluateScripts(tweets);
      })
      .finally(() => {
        qs(".load-more").innerText = "more";
      });
  });
}

if (qs(".home-timeline")) {
  let newTweets = null;
  let tweetsCount = 0;

  window.fetchNewTweets = () => {
    if (tweetsCount > 45) return;
    fetch(`/_timeline?before=${window.FIRST_TWEET_ID}`)
      .then((response) => response.text())
      .then((tweets) => {
        tweetsCount = tweets.match(new RegExp('div class="tweet"', "g")).length;
        if (tweetsCount <= 0) return;

        newTweets = tweets;
        qs(".new-tweets-notice").style.display = "block";
        if (tweetsCount > 45) {
          qs(".new-tweets-notice").innerText = `50+ new tweets`;
        } else {
          qs(".new-tweets-notice").innerText = `${tweetsCount} new tweets`;
        }
      });
  };

  setInterval(window.fetchNewTweets, 1000 * 60 * 3);

  qs(".new-tweets-notice").addEventListener("click", (_) => {
    if (tweetsCount > 45) {
      window.location.reload();
      return;
    }
    qs(".home-timeline").insertAdjacentHTML("afterbegin", newTweets);
    evaluateScripts(newTweets);

    newTweets = null;
    qs(".new-tweets-notice").style.display = "none";
  });
}
