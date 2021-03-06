/**
 * generated by Xtext
 */
package org.eclipse.xtext.example.arithmetics.validation;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import java.math.BigDecimal;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.example.arithmetics.arithmetics.ArithmeticsPackage.Literals;
import org.eclipse.xtext.example.arithmetics.arithmetics.Div;
import org.eclipse.xtext.example.arithmetics.arithmetics.Evaluation;
import org.eclipse.xtext.example.arithmetics.arithmetics.Expression;
import org.eclipse.xtext.example.arithmetics.arithmetics.FunctionCall;
import org.eclipse.xtext.example.arithmetics.arithmetics.NumberLiteral;
import org.eclipse.xtext.example.arithmetics.interpreter.Calculator;
import org.eclipse.xtext.example.arithmetics.validation.AbstractArithmeticsValidator;
import org.eclipse.xtext.validation.Check;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;

/**
 * Custom validation rules.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
@SuppressWarnings("all")
public class ArithmeticsValidator extends AbstractArithmeticsValidator {
  @Inject
  private Calculator calculator;
  
  @Check
  public void checkDivByZero(final Div div) {
    Expression _right = div.getRight();
    final BigDecimal bigDecimal = this.calculator.evaluate(_right);
    double _doubleValue = bigDecimal.doubleValue();
    boolean _equals = (_doubleValue == 0.0);
    if (_equals) {
      this.error("Division by zero detected.", Literals.DIV__RIGHT);
    }
  }
  
  public final static String NORMALIZABLE = "normalizable-expression";
  
  @Check
  public void checkNormalizable(final Expression expr) {
    boolean _or = false;
    if ((expr instanceof NumberLiteral)) {
      _or = true;
    } else {
      _or = ((expr instanceof NumberLiteral) || (expr instanceof FunctionCall));
    }
    if (_or) {
      return;
    }
    Evaluation _containerOfType = EcoreUtil2.<Evaluation>getContainerOfType(expr, Evaluation.class);
    boolean _notEquals = (!Objects.equal(_containerOfType, null));
    if (_notEquals) {
      return;
    }
    final TreeIterator<EObject> contents = expr.eAllContents();
    boolean _hasNext = contents.hasNext();
    boolean _while = _hasNext;
    while (_while) {
      {
        final EObject next = contents.next();
        if ((next instanceof FunctionCall)) {
          return;
        }
      }
      boolean _hasNext_1 = contents.hasNext();
      _while = _hasNext_1;
    }
    final BigDecimal decimal = this.calculator.evaluate(expr);
    String _string = decimal.toString();
    int _length = _string.length();
    boolean _lessEqualsThan = (_length <= 8);
    if (_lessEqualsThan) {
      String _plus = ("Expression could be normalized to constant \'" + decimal);
      String _plus_1 = (_plus + "\'");
      String _string_1 = decimal.toString();
      this.warning(_plus_1, 
        null, 
        ValidationMessageAcceptor.INSIGNIFICANT_INDEX, 
        ArithmeticsValidator.NORMALIZABLE, _string_1);
    }
  }
}
