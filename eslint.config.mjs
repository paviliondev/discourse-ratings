import DiscourseRecommended from "@discourse/lint-configs/eslint";

export default [
  ...DiscourseRecommended,
  {
    rules: {
      "simple-import-sort/imports": "off",
      "discourse/ui-kit-imports": "off",
      "discourse/i18n-import-location": "off",
      "discourse/moved-packages-import-paths": "off",
      "discourse/deprecated-imports": "off",
      "discourse/no-computed-macros": "off",
    },
  },
];
