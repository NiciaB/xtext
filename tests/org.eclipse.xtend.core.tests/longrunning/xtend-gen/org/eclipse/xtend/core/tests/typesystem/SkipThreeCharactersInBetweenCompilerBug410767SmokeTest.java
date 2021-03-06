/**
 * Copyright (c) 2013 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.eclipse.xtend.core.tests.typesystem;

import org.eclipse.xtend.core.tests.typesystem.AbstractCompilerBug410767SmokeTest;
import org.eclipse.xtext.xbase.lib.IntegerRange;

/**
 * @author Sebastian Zarnekow - Initial contribution and API
 */
@SuppressWarnings("all")
public class SkipThreeCharactersInBetweenCompilerBug410767SmokeTest extends AbstractCompilerBug410767SmokeTest {
  public void assertNonSmoking(final CharSequence input) throws Exception {
    final String string = input.toString();
    int _length = input.length();
    boolean _greaterThan = (_length > 1);
    if (_greaterThan) {
      int _length_1 = input.length();
      int _minus = (_length_1 - 4);
      IntegerRange _upTo = new IntegerRange(0, _minus);
      for (final Integer i : _upTo) {
        String _substring = string.substring(0, (i).intValue());
        int _plus = ((i).intValue() + 3);
        String _substring_1 = string.substring(_plus);
        String _plus_1 = (_substring + _substring_1);
        this.processFile(_plus_1);
      }
    }
  }
}
