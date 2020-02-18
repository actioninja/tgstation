import { Component } from "inferno";
import { refocusLayout } from "../refocus";
import { createLogger } from "../logging";
import { Box } from "../components";
import { PanelTabs } from "./tabs";

const logger = createLogger('Internal');

export class Panel extends Component {
  componentDidMount() {
    refocusLayout();
  }

  render() {
    const { props } = this;
    const { state, dispatch } = props;
    const { config, data } = state;
    const {
      theme,
    } = config;

    logger.info(data);

    return (
      <div className={'theme-' + theme}>
        <div className="Layout">
          <Box m={1}>
            <PanelTabs state={state} />
          </Box>
        </div>
      </div>
    );
  }
}
