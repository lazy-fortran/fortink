// Equivalent to ink_filter_leaf for the language comparison. Geometry and
// browser scheduling are shared by both implementations.
export class InkModel {
  reset() { this.started = false; }
  constructor() { this.reset(); }
  batch(input, width, output = new Float32Array(input.length / 4 * 3)) {
    for (let i = 0, j = 0; i < input.length; i += 4, j += 3) {
      const x = input[i], y = input[i + 1], t = input[i + 2], p = input[i + 3];
      if (!this.started) {
        this.x = x; this.y = y; this.t = t - 1; this.p = p; this.started = true;
      }
      const dt = Math.max(0.001, t - this.t);
      const dx = x - this.x, dy = y - this.y;
      const a = dt / (dt + 0.003 / (1 + Math.sqrt(dx * dx + dy * dy) / (dt * 40)));
      this.x += a * dx; this.y += a * dy;
      this.p += dt / (dt + 0.008) * (p - this.p);
      this.t = t;
      output[j] = this.x; output[j + 1] = this.y;
      output[j + 2] = width * (0.18 + 0.82 * this.p) / 2;
    }
    return output;
  }
}
