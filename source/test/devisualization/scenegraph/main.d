/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.scenegraph.main;
import devisualization.scenegraph.base.overlayed;
import devisualization.scenegraph.interfaces.elements;

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

    test();
}

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