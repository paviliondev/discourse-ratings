import Component from "@glimmer/component";
import RatingStar from "./rating-star";

export default class StarRating extends Component {
  stars = [1, 2, 3, 4, 5];

  <template>
    <span class="star-rating">{{#each this.stars as |star|}}
        <RatingStar
          @value={{star}}
          @rating={{@rating}}
          @enabled={{@enabled}}
          @onChange={{@onChange}}
        /><i></i>
      {{/each}}</span>
  </template>
}
