import React from 'react';
import Tab from 'material-ui/Tabs/Tab';
import GeolocationOrInput from './GeolocationOrInput';
import { setEndpoint, setUseCurrent } from '../../action/EndpointActions';
import { executeSearch } from '../../action/SearchActions';
import SearchModal from './SearchModal';

import { intlShape } from 'react-intl';

class OneTabSearchModal extends React.Component {
  static contextTypes = {
    getStore: React.PropTypes.func.isRequired,
    executeAction: React.PropTypes.func.isRequired,
    intl: intlShape.isRequired,
  };

  static propTypes = {
    closeModal: React.PropTypes.func.isRequired,
    customOnSuggestionSelected: React.PropTypes.func,
    customTabLabel: React.PropTypes.string,
    endpoint: React.PropTypes.object,
    initialValue: React.PropTypes.string.isRequired,
    modalIsOpen: React.PropTypes.oneOfType(
      [React.PropTypes.bool, React.PropTypes.string]).isRequired,
    target: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.string]),
  };

  componentDidUpdate() {
    if (this.props.modalIsOpen) {
      setTimeout(() => {
        if (this.refs.geolocationOrInput != null &&
            this.refs.geolocationOrInput.refs.searchInput.refs.autowhatever != null &&
            this.refs.geolocationOrInput.refs.searchInput.refs.autowhatever.refs.input != null) {
          this.refs.geolocationOrInput.refs.searchInput.refs.autowhatever.refs.input.focus();
        }
      }, 0);

      if (!this.props.endpoint) {
        this.context.executeAction(executeSearch, {
          input: '',
          type: 'endpoint',
        });
      } else if (this.props.target === 'origin') {
        this.context.executeAction(executeSearch, {
          input: this.context.getStore('EndpointStore').getOrigin().address || '',
          type: 'endpoint',
        });
      } else if (this.props.target === 'destination') {
        this.context.executeAction(executeSearch, {
          input: this.context.getStore('EndpointStore').getDestination().address || '',
          type: 'endpoint',
        });
      }
    }
  }

  render() {
    const searchTabLabel = (this.props.customTabLabel ?
      this.props.customTabLabel :
      this.context.intl.formatMessage({
        id: this.props.target || 'origin',
        defaultMessage: this.props.target || 'origin',
      }));

    return (
      <SearchModal
        selectedTab="tab"
        modalIsOpen={this.props.modalIsOpen}
        closeModal={this.props.closeModal}
      >
        <Tab className="search-header__button--selected" label={searchTabLabel} value="tab">
          <GeolocationOrInput
            ref="geolocationOrInput"
            initialValue={this.props.initialValue}
            type="endpoint"
            endpoint={this.props.endpoint}
            onSuggestionSelected={(() => {
              if (this.props.customOnSuggestionSelected) {
                return this.props.customOnSuggestionSelected;
              }
              return (name, item) => {
                if (item.type === 'CurrentLocation') {
                  this.context.executeAction(setUseCurrent, this.props.target);
                } else {
                  this.context.executeAction(setEndpoint, {
                    target: this.props.target,
                    endpoint: {
                      lat: item.geometry.coordinates[1],
                      lon: item.geometry.coordinates[0],
                      address: name,
                    },
                  });
                }

                return this.props.closeModal();
              };
            })()}
          />
        </Tab>
      </SearchModal>);
  }
}

export default OneTabSearchModal;