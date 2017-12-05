public class PID : Object, gui.PIDController {
  public double kp { get; set; default=0; } //setter
  public double ki { get; set; default=0; } //setter
  public double kd { get; set; default=0; } //setter
  public int TimeInMs { get; set; default=0; } //getter, setter
  private double Error;
  private double ErrorSum;
  private double ErrorOld;
  private double _Result;
  public double Result { get { return this._Result; } default=0; } //getter
  private double _OldResult;
  public double OldResult { get { return this._OldResult; } default=0; } //getter

  public PID(){}

  public void reset(){
    this.kp=0;
    this.ki=0;
    this.kd=0;
    this.TimeInMs=0;
    this.Error=0;
    this.ErrorSum=0;
    this.ErrorOld=0;
    this._Result=0;
    this._OldResult=0;
  }

  public void PIDcalc(double Input, double Setpoint){
    // calc error
    this.Error = Setpoint - Input;

    // TODO: anti windup

    // calculate integral over time
    this.ErrorSum = this.ErrorSum + this.Error * this.TimeInMs;

    this._OldResult = this._Result;

    // calculate P,I and D part
    // TODO: test division with 0
    this._Result = (this.kp * this.Error)
                 + (this.ki * this.ErrorSum)
                 + (this.kd * (this.Error - this.ErrorOld) / this.TimeInMs);

    this.ErrorOld = this.Error;

    // cutoff at max value
    if (this._Result > 600) {
      this._Result = 600;
    } else if (this._Result < -600) {
      this._Result = -600;
    }
    
    if (this._Result.is_nan()) {
      this._Result = 0;
    }
  }
}
