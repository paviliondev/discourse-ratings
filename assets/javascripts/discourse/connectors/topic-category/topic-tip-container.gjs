import Component from "@glimmer/component";
import TopicRatingTip from "../../components/topic-rating-tip";

export default class TopicTipContainerConnector extends Component {
  static shouldRender(_, context) {
    return (
      context.siteSettings.rating_enabled &&
      context.siteSettings.rating_show_topic_tip
    );
  }

  <template>
    <div class="topic-category-outlet topic-tip-container">{{#if
        @topic.show_ratings
      }}
        <TopicRatingTip @details="topic.tip.ratings.details" />
      {{/if}}</div>
  </template>
}
