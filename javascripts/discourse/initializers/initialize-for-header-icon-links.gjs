import { dasherize } from "@ember/string";
import concatClass from "discourse/helpers/concat-class";
import { withPluginApi } from "discourse/lib/plugin-api";
import { escapeExpression } from "discourse/lib/utilities";
import icon from "discourse-common/helpers/d-icon";
import isValidUrl from "../lib/isValidUrl";

function buildIcon(iconNameOrImageUrl, title) {
  if (isValidUrl(iconNameOrImageUrl)) {
    return <template>
      <img src={{iconNameOrImageUrl}} aria-hidden="true" />
      <span class="sr-only">{{title}}</span>
    </template>;
  } else {
    return <template>{{icon iconNameOrImageUrl label=title}}</template>;
  }
}

export default {
  name: "header-icon-links",
  initialize() {
    withPluginApi("0.8.41", (api) => {
      // const controller = api.container.lookup("controller:topic");
      // const model = controller.get("model");
      // console.log(model);
      // const controller2 = Discourse.__container__.lookup("controller:topic");
      // const model2 = controller2.get("model");
      // console.log(model2);
      api.onPageChange(() => {
        console.log("Page changed");
        let pathname = window.location.pathname;
        if (pathname.startsWith("/t/")){
            let topic_id = pathname.split("/")[3];
            document.getElementById('east-xj').href = `https://east.xjtu.app/tn/${topic_id}`;
        } else{
          document.getElementById('east-xj').href = `https://east.xjtu.app`;
        }
      });
      // api.registerTopicFooterButton({
      //   id: "flag",
      //   icon: "flag",
      //   action(context) { console.log(context.get("topic.external_id")) },
      // });
      try {
        const site = api.container.lookup("service:site");
        let links = settings.header_links;
        if (site.mobileView) {
          links = links.filter(
            (link) => link.view === "vmo" || link.view === "vdm"
          );
        } else {
          links = links.filter(
            (link) => link.view === "vdo" || link.view === "vdm"
          );
        }

        links.forEach((link, index) => {
          const iconTemplate = buildIcon(link.icon, link.title);
          const className = `header-icon-${dasherize(link.title)}`;
          const target = link.target === "blank" ? "_blank" : "";
          const rel = link.target ? "noopener" : "";
          const isLastLink =
            index === links.length - 1 ? "last-custom-icon" : "";

          let style = "";
          if (link.width) {
            style = `width: ${escapeExpression(link.width)}px`;
          }
          let a_custom_id = link.url === "https://east.xjtu.app" ? "east-xj" : null;

          const iconComponent = <template>
            <li
              class={{concatClass
                "custom-header-icon-link"
                className
                link.view
                isLastLink
              }}
            >
              <a
                class="btn no-text icon btn-flat"
                id={{a_custom_id}}
                href={{link.url}}
                title={{link.title}}
                target={{target}}
                rel={{rel}}
                style={{style}}
              >
                {{iconTemplate}}
              </a>
            </li>
          </template>;

          const beforeIcon = ["chat", "search", "hamburger", "user-menu"];

          // api.registerValueTransformer("home-logo-href", () => {
          //   const currentUser = api.getCurrentUser();
          //   return `https://xjtu.app/u/${currentUser.username}`;
          // });

          api.headerIcons.add(link.title, iconComponent, {
            before: beforeIcon,
          });
        });
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(
          error,
          "There's an issue in the header icon links component. Check if your settings are entered correctly"
        );
      }
    });
  },
};
