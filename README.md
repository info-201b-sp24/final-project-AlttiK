# NBA Clutch Predictor

## INFO 201 "Foundational Skills for Data Science"

Authors: Altti Koskinen

[Shiny App Link](https://alttik.shinyapps.io/final-project-alttik/)

Note: If there are errors, refresh/reopen the link and it should work

# Introduction

<p>This project aims to analyze and understand NBA player and team clutch performance using data from:</p>
      <ul>
        <li>Clutch free throw attempts/percent made compared to overall free throw attempt/percent made</li>
        <li>Clutch shots taken, made, and percentage</li>
      </ul>
      <p>Clutch moments in basketball games are high-pressure and show how players deal with that pressure and use their skills. Some research questions include:</p>
      <ul>
        <li>How do clutch situations impact free throws and field goals made?</li>
        <li>How much does a player's clutch factor play into winning games?</li>
        <li>Does clutch shot efficiency rise with more attempts?</li>
      </ul>
      <p>These questions are important because they can enhance people's appreciation for players' skills when they matter most and how pressure impacts performance efficiency in general.</p>

# Conclusion / Summary Takeaways

Since the 1996-97 NBA season, 39903 clutch shots have been taken, with an average of 48% success percentage. When looking at that number compared to normal shots, it is obvious the effect of pressure has on players. Free throw percentage is also down a considerable percentage. Surprisingly, harder shots are made very slightly more on average by 1.38 percent, though, the range for adjusted shot percent is very high. Finally, the best player based on impact is Kobe, this number is the "difference between the team's win probability if the shot is made vs. if it was missed." Players with higher numbers have a much higher impact on a team's chances of winning. I will go over a couple of important insights from this project here.

Insight 1:

The first notable insight found from this project was over time, the more clutch shots a player attempts, the more their average will trend toward 50%. The graph provided shows this trend, as players with more and more attempts converge toward 50%. It shows how varied players who don't attempt many shots are, players with less than 200 attempts fall into a large range between 30%-70%.
![Clutch Shot Pct Chart](./plot1.png)

Insight 2:

The second insight was on the overall impact of players and how most fall into the area of 0.008-0.016. This histogram visualizes where players fall for impact on a team. This number is found by looking at the swing (effect on team win probability based on a shot going in or not) made per game. The histogram is also right skew meaning most players fall in the height of the bell curve while the farther right you look the less and less players there are.
![Swing Per Game Chart](./plot2.png)

Insight 3:

The final insight I found was how games played, which essentially translates to experience, do not end up affecting how often a player can make more and more difficult clutch shots. This scatter plot displays players' games played and their adjusted clutch shot percentage, which is based on the difficulty of a shot. "Clutch" players end up falling into the positives for making difficult shots regardless of games played and only slightly compacts as the number of games played increases. The distribution is still about equal for a positive or negative adjusted percentage.
![Adjusted Clutch Shot Pct Chart](./plot3.png)

Most Important Insight:

From these 3 key insights, I see the first one as the most important as it shows that experience does have an important affect on if a player can make high-pressure shots. While it ends up being closer to 50/50, the high variability in low attempts makes less experienced clutch players from being much more volatile/unpredictable.

Broader Implications:

The broader implications can be used to decide who takes crucial game-winning shots when the time comes. Beyond raw talent, the ability to thrive under pressure emerges as a defining trait of elite athletes. This trait can be improved through experience but from this project's insights, many players have more inherent "clutchness" compared to others. Coaches and team management must weigh this intangible quality alongside conventional metrics when crafting game plans and roster decisions.
