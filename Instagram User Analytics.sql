use ig_clone;

select * from comments;

select * from follows;

select * from likes;

select * from photo_tags;

select * from photos;

select * from tags;

select * from users;




# A) Marketing:
# 1. Rewarding Most Loyal Users
SELECT *
FROM (
	SELECT 
		id, username, created_at, 
		RANK() OVER(order by created_at) as joining_rank
	FROM
		users) as ranking
WHERE
	joining_rank < 6;


# 2. Remind Inactive Users to Start Posting
SELECT 
    id, username
FROM
    users
WHERE
    id NOT IN (
		SELECT 
            user_id
        FROM
            photos);


# 3. Declaring Contest Winner
CREATE VIEW likes_view AS
    (SELECT 
        photo_id, COUNT(photo_id) AS no_of_likes
    FROM
        likes
    GROUP BY photo_id);

select * from likes_view;

SELECT 
    photo_id, user_id, username, no_of_likes
FROM
    users INNER JOIN
    (SELECT 
        photo_id, user_id, no_of_likes
    FROM
        likes_view INNER JOIN 
        photos ON likes_view.photo_id = photos.id
    WHERE
        no_of_likes = (SELECT 
                MAX(no_of_likes)
            FROM
                likes_view)) AS inner_query ON users.id = inner_query.user_id;


# 4. Hashtag Researching
CREATE VIEW hashtags_view AS
    (SELECT 
        tag_id, COUNT(tag_id) AS used_no
    FROM
        photo_tags
    GROUP BY tag_id);
    
select * from hashtags_view;

SELECT * 
FROM (
	SELECT 
		tag_id, tag_name, used_no, 
		RANK() OVER(order by used_no desc) as hashtag_rank
	FROM
		hashtags_view inner join
		tags on hashtags_view.tag_id = tags.id) as ranking
WHERE
	hashtag_rank < 6;


# 5. Launch AD Campaign
CREATE VIEW users_registered_view AS
    (SELECT 
        DAYOFWEEK(created_at) as Day_of_week,
        COUNT(DAYOFWEEK(created_at)) AS Users_registered
    FROM
        users
    GROUP BY DAYOFWEEK(created_at)
    ORDER BY Day_of_week);
    
select * from users_registered_view;
    
SELECT 
    Day_of_week, Users_registered AS Most_users_registerd
FROM
    users_registered_view
WHERE
    Users_registered = (SELECT 
            MAX(Users_registered)
        FROM
            users_registered_view);


# B) Investor Metrics:
# 1. User Engagement
CREATE VIEW posts_view AS
    (SELECT 
        user_id, COUNT(id) AS no_of_posts
    FROM
        photos
    GROUP BY user_id
    ORDER BY user_id);
    
SELECT 
        id, username, no_of_posts
    FROM
        users
            LEFT JOIN
        posts_view ON users.id = posts_view.user_id;
    
CREATE VIEW posts_per_user AS
    (SELECT 
        id, username, no_of_posts
    FROM
        users
            LEFT JOIN
        posts_view ON users.id = posts_view.user_id);
    
SELECT * FROM posts_per_user;

SELECT 
    COUNT(id) AS no_of_users,
    SUM(no_of_posts) AS total_no_of_posts,
    SUM(no_of_posts) / COUNT(id) AS `total number of photos on Instagram/total number of users`
FROM
    posts_per_user;


# 2. Bots & Fake Accounts
SELECT 
    user_id, username
FROM
    (SELECT 
        user_id, username, COUNT(photo_id) AS posts_liked
    FROM
        likes
    INNER JOIN users ON likes.user_id = users.id
    GROUP BY user_id) AS likes_no
WHERE
    posts_liked = (SELECT 
            COUNT(DISTINCT id) AS total_posts
        FROM
            photos);