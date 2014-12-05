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
module devisualization.scenegraph.interfaces.elements;

struct Element {
	ulong type;
	ulong idHash;
}

class Element2D {
	Element _element;
	alias _element this;

	float x;
	float y;

	float width; //x-axis
	float height; //y-axis

	Element2D[] elements;

	private {
		size_t othersLikeMe;
	}

	this(Element element, float x, float y, float width, float height) {
		this._element = element;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	this(Element element, float x, float y, float width, float height, Element2D[] elements) {
		this._element = element;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.elements = elements;
	}

	void apply(void delegate(Element2D) f) {
		foreach(e; elements) {
			f(e);
			if (e.elements.length > 0)
				e.apply(f);
		}
	}

	void apply(void delegate(Element2D, uint) f, uint recursive=0) {
		foreach(e; elements) {
			f(e, recursive);
			if (e.elements.length > 0)
				e.apply(f, recursive + 1);
		}
	}

	void apply(bool delegate(Element2D) f) {
		foreach(e; elements) {
			if (f(e)) return;
			if (e.elements.length > 0)
				e.apply(f);
		}
	}
	
	void apply(bool delegate(Element2D, uint) f, uint recursive=0) {
		foreach(e; elements) {
			if (f(e, recursive)) return;
			if (e.elements.length > 0)
				e.apply(f, recursive + 1);
		}
	}

	void updateHashId(Element2D root) {
		othersLikeMe = 0;

		root.apply((Element2D e) {
			if (e.type == _element.type && e.x == x && e.y == y && e.width == width && e.height == height)
				othersLikeMe++;
		});

		idHash = typeid(typeof(this)).getHash(&this);
	}
}

class Element3D : Element2D {
	alias _element this; //bug

	float z;
	float depth; //z-axis

	Element3D[] elements;

	@disable
	this(Element element, float x, float y, float width, float height);
	@disable
	this(Element element, float x, float y, float width, float height, Element2D[] children);

	this(Element element, float x, float y, float z, float width, float height, float depth) {
		super(element, x, y, width, height);
		this.z = z;
		this.depth = depth;
	}

	this(Element element, float x, float y, float z, float width, float height, float depth, Element3D[] children) {
		super(element, x, y, width, height);
		this.z = z;
		this.depth = depth;
		this.elements = children;
	}

	@disable override
	void apply(void delegate(Element2D) f) {}
	@disable override
	void apply(void delegate(Element2D, uint) f, uint recursive=0) {}

	@disable override
	void apply(bool delegate(Element2D) f) {}
	@disable override
	void apply(bool delegate(Element2D, uint) f, uint recursive=0) {}

	void apply(void delegate(Element3D) f) {
		foreach(e; elements) {
			f(e);
			if (e.elements.length > 0)
				e.apply(f);
		}
	}

	void apply(void delegate(Element3D, uint) f, uint recursive=0) {
		foreach(e; elements) {
			f(e, recursive);
			if (e.elements.length > 0)
				e.apply(f, recursive + 1);
		}
	}

	void apply(bool delegate(Element3D) f) {
		foreach(e; elements) {
			if (f(e)) return;
			if (e.elements.length > 0)
				e.apply(f);
		}
	}
	
	void apply(bool delegate(Element3D, uint) f, uint recursive=0) {
		foreach(e; elements) {
			if (f(e, recursive)) return;
			if (e.elements.length > 0)
				e.apply(f, recursive + 1);
		}
	}
}