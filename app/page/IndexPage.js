import React from 'react';
import Config from '../config';
import { clearDestination } from '../action/EndpointActions';
import { reset, forceCitybikeState } from '../action/ItinerarySearchActions';
import { unsetSelectedTime } from '../action/TimeActions';
import FeedbackPanel from '../component/feedback/feedback-panel';
import FrontPagePanel from '../component/front-page/FrontPagePanel';
import MapWithTracking from '../component/map/MapWithTracking';
import DefaultNavigation from '../component/navigation/DefaultNavigation';
import SearchMainContainer from '../component/search/SearchMainContainer';

class IndexPage extends React.Component {
  static contextTypes = {
    executeAction: React.PropTypes.func.isRequired,
    location: React.PropTypes.object.isRequired,
  };

  componentWillMount = () => {
    this.resetToCleanState();
  }

  componentDidMount() {
    const search = this.context.location.search;

    if (search && search.indexOf('citybikes') >= -1) {
      this.context.executeAction(forceCitybikeState);
    }
  }

  resetToCleanState = () => {
    this.context.executeAction(clearDestination);
    this.context.executeAction(unsetSelectedTime);
    this.context.executeAction(reset);
  }

  render() {
    return (
      <DefaultNavigation
        className="front-page fullscreen"
        disableBackButton
        showDisruptionInfo
        title={Config.title}
        showLogo={Config.useNavigationLogo}
      >
        <MapWithTracking showStops>
          <SearchMainContainer />
        </MapWithTracking>
        <FrontPagePanel />
        <FeedbackPanel />
      </DefaultNavigation>
    );
  }
}

export default IndexPage;
