-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////___/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\___/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////___\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\__________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\___________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\_____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Hans Andersen
-- Your Student Number: 1508193
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT id as videoID, title
FROM video
WHERE id NOT IN (
    SELECT sourceVideoID
    FROM annotation);


-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT videoID, username, ratingTime 
FROM rating
INNER JOIN user
ON rating.linkedUser = user.id
WHERE ratingTime = (
	SELECT MAX(ratingTime) FROM rating
);

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT videoID, title 
FROM ((video 
INNER JOIN cocreator ON videoID = id)
INNER JOIN content_creator ON creatorID = content_creator.id)
WHERE (
	screenName = 'TaylorSwiftOfficial' AND viewCount > 1000000
);

-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT destinationVideoID, (SELECT title FROM video WHERE id = tmp.destinationVideoID) AS videoTitle, tmp.cnt
FROM (
	SELECT destinationVideoID, COUNT(*) AS cnt
	FROM video
	INNER JOIN annotation ON video.id = annotation.sourceVideoID
	GROUP BY destinationVideoID
    
) AS tmp
WHERE cnt = (
	SELECT MAX(cnt) FROM(
		SELECT destinationVideoID , COUNT(*) AS cnt
		FROM video
		INNER JOIN annotation ON video.id = annotation.sourceVideoID
		GROUP BY destinationVideoID
    ) as tmp2
);

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT videoID, 
	(SELECT uploaded FROM video WHERE video.id = videoID) AS uploadedTime,
    (SELECT COUNT(*) FROM rating WHERE rating.videoID = video_hashtag.videoID) as ratingCount

FROM (video_hashtag
	INNER JOIN hashtag ON hashtagID = hashtag.id)
    
WHERE video_hashtag.hashtagID IN (
	SELECT id
    FROM hashtag
    WHERE tag = '#memes'
)
AND videoID IN (
	SELECT rating.videoID
	FROM rating
	GROUP BY rating.videoID
    HAVING COUNT(*) >= 3
);

-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

-- AT THIS question, i realised i was overcomplicating my previous querys after getting some guidance in a tutorial XD
-- and began making them shorter and simpler :) 

SELECT username, realName, screenName
FROM user
INNER JOIN content_creator ON user.id = content_creator.linkedUser
INNER JOIN cocreator ON content_creator.id = cocreator.creatorID
INNER JOIN rating ON rating.videoID = cocreator.videoID
WHERE reputation < 50
GROUP BY username, realName,screenName
HAVING COUNT(DISTINCT cocreator.videoID) >= 3 AND COUNT(rating.videoID) >=6 ;

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT tag, cnt AS commentCount
FROM ( 
	SELECT tag, COUNT(hashtag.tag) AS cnt
	FROM hashtag
	INNER JOIN video_hashtag ON hashtag.id = video_hashtag.hashtagID
	INNER JOIN rating ON video_hashtag.videoID = rating.videoID
	WHERE comment LIKE '%thank you%' OR comment LIKE '%well done%'
	GROUP BY tag
) as tmp
WHERE cnt = (
	SELECT COUNT(hashtag.tag) AS cnt
	FROM hashtag
	INNER JOIN video_hashtag ON hashtag.id = video_hashtag.hashtagID
	INNER JOIN rating ON video_hashtag.videoID = rating.videoID
	WHERE comment LIKE '%thank you%' OR comment LIKE '%well done%'
	GROUP BY tag
    ORDER BY cnt desc 
    LIMIT 1
);

-- Limit 1 might make it seem like i dont return multiple values! But this is just to find the highest count,
-- and return all hashtags that equals this count, i.e. possibly multiple occurences

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8


SELECT tag as hashtag,  COUNT(hashtag.tag) AS cnt, SUM(duration) AS totalDuration
FROM video_hashtag
INNER JOIN annotation ON annotation.destinationVideoID = video_hashtag.videoID
INNER JOIN hashtag ON video_hashtag.hashtagID = hashtag.id
GROUP BY tag
HAVING cnt IN (
	SELECT cnt2
	FROM (
		SELECT COUNT(destinationVideoID) as cnt2
		FROM video_hashtag
		INNER JOIN annotation ON annotation.destinationVideoID = video_hashtag.videoID
		INNER JOIN hashtag ON video_hashtag.hashtagID = hashtag.id 
		GROUP BY destinationVideoID
	) AS subquery
	GROUP BY cnt2
	ORDER BY cnt2 DESC
);


-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9


SELECT DISTINCT realName, screenName
FROM (
	SELECT c1.creatorID AS creator1, c2.creatorID AS creator2, realName, screenName
	FROM cocreator c1
	INNER JOIN cocreator c2 ON c1.videoID = c2.videoID
    INNER JOIN content_creator ON content_creator.id = c1.creatorID
	WHERE c1.creatorID <> c2.creatorID -- to ensure creators are distinct
) AS tmp
WHERE (
 creator1 IN (
	SELECT creatorID
    FROM content_creator_hashtag
    INNER JOIN hashtag ON hashtag.id = content_creator_hashtag.hashtagID
    WHERE hashtag.tag LIKE '%#memes%'
 )
)
AND (
 creator2 IN (
	SELECT creatorID
    FROM content_creator_hashtag
    INNER JOIN hashtag ON hashtag.id = content_creator_hashtag.hashtagID
    WHERE hashtag.tag LIKE '%#technology%'
 )
);


-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT DISTINCT realName, screenName
FROM (
	SELECT c1.creatorID AS creator1, c2.creatorID AS creator2, realName, screenName, cocreator.videoID
	FROM cocreator c1
	INNER JOIN cocreator c2 ON c1.videoID = c2.videoID
    INNER JOIN content_creator ON content_creator.id = c1.creatorID
    INNER JOIN cocreator ON cocreator.videoID= c1.videoID
	WHERE c1.creatorID <> c2.creatorID -- to ensure creators are distinct
) AS tmp
WHERE creator2 = (
	SELECT id
    FROM content_creator
    WHERE screenName = 'INFO20003Memes'
)
AND videoID IN (
	SELECT id
    FROM video
    WHERE uploaded >= '2023-01-01'
);


-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line