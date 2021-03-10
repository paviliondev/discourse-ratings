# discourse-ratings

![image](https://github.com/paviliondev/discourse-ratings/actions/workflows/plugin-tests.yml/badge.svg) ![image](https://github.com/paviliondev/discourse-ratings/actions/workflows/plugin-linting.yml/badge.svg)

A Discourse plugin that lets you use topics to rate things. [Read more about this plugin on Discourse Meta](https://meta.discourse.org/t/topic-star-ratings/39578).

1. Topics can be designated as 'for rating', by being posted in a category with ratings setting on (see below), or by being given the tag 'rating'.

2. Each ratings topic concerns a single thing ("rating subject"); e.g. a service or a product.

3. Users rate the rating subject by choosing a star rating when posting (i.e. in the composer).

4. The average (mean) of all the ratings in the topic is displayed under the topic title and on the relevant topic list item.  

## To do

1. Prevent a user from posting in a ratings topic more than once. Currently, users cannot rate in a ratings topic more than once.

2. Created a sorted topic list (highest to lowest) of all topics within a ratings category or with the 'rating'. Perhaps use Bayseian estimation [as discussed in the code comments](https://github.com/angusmcleod/discourse-ratings/blob/master/plugin.rb#L40).

3. Add translations for the ``category.for_ratings`` and ``composer.your_rating`` text.

4. Allow the user to select the tag(s) they wish to use to designate ratings topics in the admin config.

5. Allow the user to choose the number of total stars in a rating.

6. Allow the user to change the rating item image (i.e. use something other than stars).

## Installation

To install using docker, add the following to your app.yml in the plugins section:

```
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/angusmcleod/discourse-ratings.git
```

and rebuild docker via

```
cd /var/discourse
./launcher rebuild app
```
