scenegraph
===
Scene graph written in D.
For purpose in creating a GUI toolkit as well as a general purpose 3d game engine.

Features
-----
* Data driven elements
* 2D (overlayed) on top of 3D
* Elements have a type and a hash. Combined to form an id.
* Element type handles drawing, eventing.

Example
-----
```D
module devisualization.scenegraph.main;
import devisualization.scenegraph.base;

void main() {
    import std.stdio;

    SceneGraph3DOverlayed2D graph = new SceneGraph3DOverlayed2D;

    Element aType = Element(0x1CEB00DA, 0xB16E11B5);
    Element aType2 = Element(0xB16E11B5, 0x1CEB00DA);

    graph.add(new Element2D(aType, 50f, 50f, 100f, 100f));
    graph.add(new Element2D(aType, 0, 0, 50, 50,
                            [new Element2D(aType, 10, 10, 20, 20),
                            new Element2D(aType, 0, 0, 5, 5)]));

    graph.add(new Element3D(aType2, 50, 50, 50, 100, 100, 100));
    graph.add(new Element3D(aType2, 0, 0, 0, 50, 50, 25,
                            [new Element3D(aType2, 10, 10, 10, 20, 20, 11),
                            new Element3D(aType2, 0, 0, 0, 5, 5, 7)]));

    graph.updateIdHashes();
    writeln(graph);
    graph.draw();
}
```

If you want to hook the scenegraph into a window's events, pass it into SceneGraph3DOverlayed2D's contructor.

Some stats
-----
8ms for 30300 elements in total, for given code in release mode:
During iteration and updating of id hashes.

```D
void test() {
    import std.datetime;
    import std.stdio;

    StopWatch sw;

    SceneGraph3DOverlayed2D graph = new SceneGraph3DOverlayed2D;
    Element aType = Element(0x1CEB00DA, 0xB16E11B5);
    Element aType2 = Element(0xB16E11B5, 0x1CEB00DA);
    
    foreach(i; 0 .. 100) {
        graph.add(new Element2D(aType, i, i, i, i));
        graph.add(new Element2D(aType2, 0, i, i, 0, [new Element2D(aType, i, 0, 0, i)]));
    }
    
    foreach(i; 0 .. 10_000) {
        graph.add(new Element3D(aType, i, i, i, i, i, i));
        graph.add(new Element3D(aType2, 0, i, i, 0, 3, 3, [new Element3D(aType, i, 0, 0, i, 3, 3)]));
    }

    sw.start();

    foreach(j; 0 .. 1_000) {
        graph.updateIdHashes();

        graph.draw();
    }

    sw.stop();

    writeln("Average: ", sw.peek().usecs / 1_000);
    writeln("Average: ", sw.peek().msecs / 1_000);
    writeln("Average: ", sw.peek().seconds / 1_000);
}
```