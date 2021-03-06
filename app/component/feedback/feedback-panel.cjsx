React                 = require 'react'
MaterialModal         = require('material-ui/Dialog').default
Icon                  = require '../icon/icon'
ScoreTable            = require './score-table'
TextAreaWithCounter   = require './text-area-with-counter'
FeedbackActions       = require '../../action/feedback-action'
Feedback              = require '../../util/Feedback'

intl = require 'react-intl'
FormattedMessage = intl.FormattedMessage

FEEDBACK_OPEN_AREA_MAX_CHARS = 200

class FeedbackPanel extends React.Component

  @contextTypes:
    getStore: React.PropTypes.func.isRequired
    executeAction: React.PropTypes.func.isRequired
    intl: intl.intlShape.isRequired
    piwik: React.PropTypes.object

  constructor: ->
    super
    @state =
      postFirstQuestion: false
      modalIsOpen: false
      charLeft: FEEDBACK_OPEN_AREA_MAX_CHARS

  componentWillMount: =>
    @context.getStore('FeedbackStore').addChangeListener @onFeedbackModalChange

  componentWillUnmount: =>
    @context.getStore('FeedbackStore').removeChangeListener @onFeedbackModalChange

  shouldComponentUpdate: (nextProps, nextState) =>
    not @isInitialState nextState

  isInitialState: (state) =>
    state.selectedNPS == undefined and
    state.useThisMoreLikely == undefined and
    state.openText == undefined and
    state.charLeft == FEEDBACK_OPEN_AREA_MAX_CHARS and
    state.postFirstQuestion == false

  onFeedbackModalChange: =>
    @forceUpdate()

  closeModal: =>
    @context.executeAction FeedbackActions.closeFeedbackModal
    Feedback.recordResult(@context.piwik, @context.getStore('TimeStore').getCurrentTime().valueOf())
    @setState
      selectedNPS: undefined
      useThisMoreLikely: undefined
      openText: undefined
      charLeft: FEEDBACK_OPEN_AREA_MAX_CHARS
      postFirstQuestion: false

  answerFirstQuestion: (answer) =>
    @setState
      postFirstQuestion: true
      selectedNPS: answer
    Feedback.recordResult(@context.piwik, @context.getStore('TimeStore').getCurrentTime().valueOf(), answer)

  answerSecondQuestion: (answer) =>
    @setState
      useThisMoreLikely: answer

  onOpenTextAreaChange: (event) =>
    input = event.target.value
    @setState
      openText: input
      charLeft: FEEDBACK_OPEN_AREA_MAX_CHARS - input.length

  sendAll: =>
    Feedback.recordResult(@context.piwik, @context.getStore('TimeStore').getCurrentTime().valueOf(), @state.selectedNPS, @state.useThisMoreLikely, @state.openText)
    @closeModal()

  render: ->

    isModalOpen = @context.getStore('FeedbackStore').isModalOpen()

    lowEndLabel = <FormattedMessage id='very-unlikely'
                      defaultMessage='Very unlikely' />
    highEndLabel = <FormattedMessage id='very-likely'
                      defaultMessage="Very likely" />

    if @state.postFirstQuestion

      supplementaryQuestions =

      <div>
        <p className="feedback-question auxiliary-feedback-question">
          <FormattedMessage id='likely-to-use'
                            defaultMessage='How likely would you use the new service compared to the current reittiopas.fi?' />
        </p>

        <ScoreTable
          lowestScore=0
          highestScore=10
          handleClick={@answerSecondQuestion}
          selectedScore={if @state.useThisMoreLikely != 'undefined' then @state.useThisMoreLikely else undefined}
          lowEndLabel={lowEndLabel}
          highEndLabel={highEndLabel}
          showLabels={true}/>


        <p className="feedback-question--text-area auxiliary-feedback-question inline-block">
          <FormattedMessage id='how-to-rate-service'
                            defaultMessage='How would you rate the service?' />
        </p>

        <TextAreaWithCounter
          showCounter={true}
          maxLength={FEEDBACK_OPEN_AREA_MAX_CHARS}
          charLeft={@state.charLeft}
          handleChange={@onOpenTextAreaChange}
          counterClassName="open-feedback-counter-text"
          areaClassName="open-feedback-text-area"
        />

        <div className="send-feedback-button" onClick={@sendAll}>
          <FormattedMessage id="send"
                            defaultMessage="Send"/>
        </div>
      </div>

    <div>
      <MaterialModal
        className="feedback-modal"
        contentClassName={if @state.postFirstQuestion then "feedback-modal__container--post-first-question" else "feedback-modal__container"}
        bodyClassName={if @state.postFirstQuestion then "feedback-modal__body--post-first-question" else "feedback-modal__body"}
        autoScrollBodyContent={true}
        modal={true}
        overlayStyle={background: 'rgba(0, 0, 0, 0.541176)'}
        open={isModalOpen}
      >
        <div className="right cursor-pointer feedback-close-container" onClick={@closeModal}>
          <Icon id="feedback-close-icon" img={'icon-icon_close'} />
        </div>

        <div className="feedback-content-container">
          <p className="feedback-question">
            <FormattedMessage id='likely-to-recommend'
                              defaultMessage='How likely is it that you would recommend our service to a friend or colleague?' />
          </p>

          <ScoreTable
            lowestScore=0
            highestScore=10
            handleClick={@answerFirstQuestion}
            selectedScore={if @state.selectedNPS != 'undefined' then @state.selectedNPS else undefined}
            lowEndLabel={lowEndLabel}
            highEndLabel={highEndLabel}
            showLabels={true}/>

          {supplementaryQuestions}
        </div>
      </MaterialModal>
    </div>

module.exports = FeedbackPanel
