import { Tabs, LabeledList } from "../components";
import { map } from "common/collections";

const PanelTabs = props => {
  const { config, data } = props.state;

  const tabs = data.tabs || [];
  return (
    <Tabs>
      {tabs.map(tab => (
        <Tabs.Tab
          key={tab.name}
          label={tab.name}>
          <LabeledList>
            {map((content, label) => (
              <LabeledList.Item label={label}>
                {content}
              </LabeledList.Item>
            ))(tab.contents)}
          </LabeledList>
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
