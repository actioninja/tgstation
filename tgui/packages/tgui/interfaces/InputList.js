import { useBackend, useLocalState } from '../backend';
import { Button, Section, LabeledList, Box, ListView, Flex } from '../components';
import { Window } from '../layouts';
import { callByond, winset, runCommand } from '../byond';
import { releaseHeldKeys, KEY_ESCAPE } from '../hotkeys';
import { Component } from 'inferno';
import { map } from 'common/collections';
import { classes } from 'common/react';
import { createLogger } from '../logging';

const logger = createLogger("InputList");
export class InputList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      config: null
    };
    this.handleKeys = event => {
      const keyCode = event.keyCode;
      if (keyCode === KEY_ESCAPE) {
        releaseHeldKeys();
        winset(this.context.config.window, 'is-visible', false);
        runCommand(`uiclose ${this.context.config.ref}`);
        return;
      }
    };
  }

  closeWindow() {
    releaseHeldKeys();
    winset(this.state.config.window, 'is-visible', false);
    runCommand(`uiclose ${this.state.config.ref}`);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleKeys);
  }

  componentDidMount() {
    window.addEventListener('keydown', this.handleKeys);
  }

  render() {

    const { act, data, config } = useBackend(this.context);

    const [
      selectedEntry,
      setSelectedEntry,
    ] = useLocalState(this.context, 'selectedEntry', '');

    const {
      message,
      items = {},
    } = data;

    const buildEntries = () => {
      const ops = map((option, key) => (
        <div
          key={option}
          className={classes([
            'ListView__entry',
            selectedEntry === key && 'ListView__entry-selected',
          ])}
          onClick={() => {
            setSelectedEntry(key);
          }}
          onKeyDown={e => logger.error("Testing")}
          onDblClick={() => act('tgui:inputcallback', {
            result: selectedEntry,
          })}>
          {option}
        </div>
      ))(items);
      return Object.keys.length > 0
        ? ops : (
          <div className="ListView__noentries">
            No Entries Provided
          </div>
        );
    };

    return (
      <Window
        onKeyDown={e => {
          logger.info("Key pressed: " + e.keyCode);
        }}>
        <div className="InputList__top">
          <Window.Content scrollable
            onKeyDown={e => {
              logger.error("Key pressed: " + e.keyCode);
            }}>
            {buildEntries()}
          </Window.Content>
        </div>
        <div className="InputList__buttons" onKeyDown={e => {
          logger.error("Key pressed: " + e.keyCode);
        }}>
          <Flex>
            <Flex.Item
              grow={1}
              className={classes([
                'InputList__button',
                'InputList__button--cancel',
              ])}
              onClick={() => {
                this.closeWindow();
              }}>
              Cancel
            </Flex.Item>
            <Flex.Item
              grow={1}
              className={classes([
                'InputList__button',
                selectedEntry !== ''
                  ? 'InputList__button--select'
                  : 'InputList__button--select-disabled',
              ])}
              onClick={() => act('tgui:inputcallback', {
                result: selectedEntry,
              })}>
              Select
            </Flex.Item>
          </Flex>
        </div>
      </Window>
    );
  }
}
