import ratingList from "../../helpers/rating-list";

<template>
  {{#if @outletArgs.topic.show_ratings}}
    {{ratingList @outletArgs.topic.ratings topic=@outletArgs.topic linkTo=true}}
  {{/if}}
</template>
