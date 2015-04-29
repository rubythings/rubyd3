jsPlumb.ready(function () {

    // setup some defaults for jsPlumb.
    var instance = jsPlumb.getInstance({
        Endpoint: ["Dot", {radius: 2}],
        HoverPaintStyle: {strokeStyle: "#1e8151", lineWidth: 2 },
        ConnectionOverlays: [
            [ "Arrow", {
                location: 1,
                id: "arrow",
                length: 14,
                foldback: 0.8
            } ]
        ],
        Container: "statemachine-demo"
    });

    window.jsp = instance;

    var windows = jsPlumb.getSelector(".statemachine-demo .w");

    // initialise draggable elements.
    instance.draggable(windows);

    // bind a click listener to each connection; the connection is deleted. you could of course
    // just do this: jsPlumb.bind("click", jsPlumb.detach), but I wanted to make it clear what was
    // happening.
    instance.bind("click", function (c) {
        instance.detach(c);
    });

    // bind a connection listener. note that the parameter passed to this function contains more than
    // just the new connection - see the documentation for a full list of what is included in 'info'.
    // this listener sets the connection's internal
    // id as the label overlay's text.
    instance.bind("connection", function (info) {
        info.connection.getOverlay("label").setLabel(info.connection.id);
    });


    // suspend drawing and initialise.
    instance.batch(function () {
        instance.makeSource(windows, {
            filter: ".ep",
            anchor: "Continuous",
            connector: [ "StateMachine", { curviness: 20 } ],
            connectorStyle: { strokeStyle: "#5c96bc", lineWidth: 2, outlineColor: "transparent", outlineWidth: 4 },
            maxConnections: 5,
            onMaxConnections: function (info, e) {
                alert("Maximum connections (" + info.maxConnections + ") reached");
            }
        });

        // initialise all '.w' elements as connection targets.
        instance.makeTarget(windows, {
            dropOptions: { hoverClass: "dragHover" },
            anchor: "Continuous",
            allowLoopback: true
        });
        instance.connect({ source: 'draft', target: 'pending', overlays:[[ 'Label', { label: 'setup', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'pending', target: 'signoff', overlays:[[ 'Label', { label: 'restrict', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'pending', target: 'active', overlays:[[ 'Label', { label: 'activate', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'signoff', target: 'completed', overlays:[[ 'Label', { label: 'finish', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'signoff', target: 'cancelled', overlays:[[ 'Label', { label: 'kill', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'pending', target: 'cancelled', overlays:[[ 'Label', { label: 'kill', location: 0.25, id:'myLabel' } ]]});
        instance.connect({ source: 'draft', target: 'cancelled', overlays:[[ 'Label', { label: 'kill', location: 0.25, id:'myLabel' } ]]});

    });

    jsPlumb.fire("jsPlumbDemoLoaded", instance);

});