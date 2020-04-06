import { Component } from "inferno";
import { Box } from "./Box";
import { classes } from "common/react";
import { map } from "common/collections";

export class ListView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: "",
    };
  }

  setSelected(selected) {
    this.setState({
      selected: selected,
    });
    this.props.onSelected(selected, this.props.entries[selected]);
  }

  buildEntries() {
    const { entries = {} } = this.props;
    const {
      selected,
    } = this.state;
    const ops = map((option, key) => (
      <div
        key={option}
        className={classes([
          'ListView__entry',
          selected === key && 'ListView__entry-selected',
        ])}
        onClick={() => {
          this.setSelected(key);
        }}>
        {option}
      </div>
    ))(entries);
    return Object.keys.length > 0
      ? ops : (
        <div className="ListView__noentries">
          No Entries Provided
        </div>
      );
  }

  render() {
    const {
      height = 30,
    } = this.props;

    return (
      <div className="ListView">
        <Box
          mb={1}
          height={height}
          className={classes([
            'ListView__container',
          ])}>
          {this.buildEntries()}
        </Box>
      </div>
    );
  }
}
