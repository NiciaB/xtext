package org.eclipse.xtend.core.tests.imports

import javax.inject.Inject
import org.eclipse.xtend.core.tests.AbstractXtendTestCase
import org.eclipse.xtext.resource.XtextResource
import org.junit.Test
import org.eclipse.xtext.xbase.imports.ImportOrganizer

class ImportOrganizerTest extends AbstractXtendTestCase {

	@Inject ImportOrganizer importOrganizer

	def protected assertIsOrganizedTo(CharSequence model, CharSequence expected) {
		val xtendFile = file(model.toString, true)
		val changes = importOrganizer.getOrganizedImportChanges(xtendFile.eResource as XtextResource)
		val builder = new StringBuilder(model)
		for(it: changes.sortBy[offset].reverse)
			builder.replace(offset, offset + length, text)
		assertEquals(expected.toString, builder.toString)
	}

	@Test def testSimple() {
		'''
			package foo

			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			package foo

			import java.io.Serializable
			
			class Foo implements Serializable {}
		''')
	}

	@Test def testDefaultPackage() {
		'''
			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			class Foo implements Serializable {}
		''')
	}

	@Test def testDefaultPackageLeadingWhitespace() {
		'''
			��
			   	
			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			class Foo implements Serializable {}
		''')
	}

	@Test def testDefaultPackageWithJavaDoc() {
		'''
			/**
			 * some doc
			 */
			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			/**
			 * some doc
			 */
			class Foo implements Serializable {}
		''')
	}

	@Test def testWithHeader() {
		'''
			/**
			 * some header
			 */
			package foo
			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			/**
			 * some header
			 */
			package foo

			import java.io.Serializable

			class Foo implements Serializable {}
		''')
	}

	@Test def testWithHeaderAndJavaDoc() {
		'''
			/**
			 * some header
			 */
			package foo
			/**
			 * some doc
			 */
			class Foo implements java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			/**
			 * some header
			 */
			package foo

			import java.io.Serializable

			/**
			 * some doc
			 */
			class Foo implements Serializable {}
		''')
	}

	@Test def testGetOrganizedImportSection_01() {
		'''
			import java.lang.String
			import java.util.List

			class Foo {
			  def void test(List<String> s) {
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			class Foo {
			  def void test(List<String> s) {
			  }
			}
		''')
	}

	@Test def testGetOrganizedImportSection_02() {
		'''
			import java.lang.String
			import java.util.List
			import java.util.List
			import java.util.List
			import java.lang.Integer

			class Foo {
			  def void test(List<String> s) {
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			class Foo {
			  def void test(List<String> s) {
			  }
			}
		''')
	}

	@Test def testGetOrganizedImportSection_03() {
		'''
			import java.util.*

			class Foo {
			  def void test(List<String> s) {
			    val x = newArrayList('foo','bar')
			    Collections::sort(x)
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.Collections
			import java.util.List

			class Foo {
			  def void test(List<String> s) {
			    val x = newArrayList('foo','bar')
			    Collections::sort(x)
			  }
			}
		''')
	}

	@Test def testGetOrganizedImportSection_04() {
		'''
			import java.util.*
			import java.io.*

			class Foo {
			  def void test(List<String> s) {
			    val x = new ArrayList<Map<StringBuilder,? extends Serializable>>()
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable
			import java.util.ArrayList
			import java.util.List
			import java.util.Map

			class Foo {
			  def void test(List<String> s) {
			    val x = new ArrayList<Map<StringBuilder,? extends Serializable>>()
			  }
			}
		''')
	}

	@Test def testGetOrganizedImportSection_05() {
		'''
			import java.util.*
			import java.io.*
			import com.google.inject.Inject

			class Foo {
			  @Inject String s
			  def void test(List<String> s) {
			    val x = new ArrayList<Map<StringBuilder,? extends Serializable>>()
			  }
			}
		'''.assertIsOrganizedTo('''
			import com.google.inject.Inject
			import java.io.Serializable
			import java.util.ArrayList
			import java.util.List
			import java.util.Map

			class Foo {
			  @Inject String s
			  def void test(List<String> s) {
			    val x = new ArrayList<Map<StringBuilder,? extends Serializable>>()
			  }
			}
		''')
	}

	@Test def testInnerClasses_01() {
		'''
			class Foo {
			  def void test(org.eclipse.emf.ecore.resource.Resource$Factory a, org.eclipse.emf.ecore.resource.Resource$Factory$Registry b) {
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def void test(Resource$Factory a, Resource$Factory$Registry b) {
			  }
			}
		''')

	}

	@Test def testInnerClasses_02() {
		'''
			import org.eclipse.emf.ecore.resource.Resource
			import org.eclipse.emf.ecore.EPackage

			class Foo {
			  def test() {
			    val x = Resource$Factory$Registry::INSTANCE
			    val y = EPackage$Registry::INSTANCE
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.EPackage
			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def test() {
			    val x = Resource$Factory$Registry::INSTANCE
			    val y = EPackage$Registry::INSTANCE
			  }
			}
		''')
	}

	@Test def testInnerClasses_03() {
		'''
			class Foo {
			  def test() {
				 typeof(org.eclipse.emf.ecore.resource.Resource$Factory) == typeof(org.eclipse.emf.ecore.resource.Resource$Factory$Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def test() {
				 typeof(Resource$Factory) == typeof(Resource$Factory$Registry)
			  }
			}
		''')
	}

	@Test def testInnerClasses_04() {
		'''
			import org.eclipse.emf.ecore.resource.Resource
			import org.eclipse.emf.ecore.EPackage

			class Foo {
			  def test() {
			    typeof(Resource$Factory$Registry) == typeof(EPackage$Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.EPackage
			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def test() {
			    typeof(Resource$Factory$Registry) == typeof(EPackage$Registry)
			  }
			}
		''')
	}

	@Test def testInnerClasses_05() {
		'''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Registry

			class Foo {
			  def test() {
			    typeof(Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Registry

			class Foo {
			  def test() {
			    typeof(Registry)
			  }
			}
		''')
	}

	@Test def testNameClashSameFileWins_1() {
		'''
			package foo

			class Foo {
				java.lang.String x
			}

			class String {}
		'''.assertIsOrganizedTo('''
			package foo

			class Foo {
				java.lang.String x
			}

			class String {}
		''')
	}

	@Test def testNameClashSameFileWins() {
		'''
			package foo

			class Foo implements java.io.Serializable {}

			class Serializable {}
		'''.assertIsOrganizedTo('''
			package foo

			class Foo implements java.io.Serializable {}

			class Serializable {}
		''')
	}

	@Test def testNameClashOrder_01() {
		'''
			class Foo {
			  def java.awt.List test(java.util.List<String> s) {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.awt.List

			class Foo {
			  def List test(java.util.List<String> s) {
			    return null
			  }
			}
		''')
	}

	@Test def testNameClashOrder_02() {
		'''
			class Foo {
			  def java.util.List<String> test(java.awt.List s) {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			class Foo {
			  def List<String> test(java.awt.List s) {
			    return null
			  }
			}
		''')
	}

	@Test def testNameClashMoreCommon() {
		'''
			class Foo {
			  def java.util.List<String> test(java.awt.List s) {
			  	new java.awt.List()
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.awt.List

			class Foo {
			  def java.util.List<String> test(List s) {
			  	new List()
			    return null
			  }
			}
		''')
	}

	@Test def testNameClashInnerClasses() {
		'''
			import org.eclipse.xtext.xbase.XbasePackage
			import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage

			class Foo {
			  def void test(XbasePackage$Literals x, XAnnotationsPackage$Literals y) {
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.xtext.xbase.XbasePackage
			import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage

			class Foo {
			  def void test(XbasePackage$Literals x, XAnnotationsPackage$Literals y) {
			  }
			}
		''')
	}


	@Test def testNameClashInnerClassesWithPreference() {
		'''
			import org.eclipse.xtext.xbase.XbasePackage$Literals
			import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage

			class Foo {
			  def void test(Literals x, XAnnotationsPackage$Literals y) {
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.xtext.xbase.XbasePackage$Literals
			import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage

			class Foo {
			  def void test(Literals x, XAnnotationsPackage$Literals y) {
			  }
			}
		''')
	}

	@Test def testStaticImport_01() {
		'''
			import static extension java.util.Collections.*
			class Foo {
			  def void test(java.util.List<String> s) {
			  sort(s)
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List
			
			import static java.util.Collections.*

			class Foo {
			  def void test(List<String> s) {
			  sort(s)
			  }
			}
		''')
	}

	@Test def testStaticImport_02() {
		'''
			import static extension java.util.Collections.*
			class Foo {
			  def void test(java.util.List<String> s) {
			  s.sort
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			import static extension java.util.Collections.*

			class Foo {
			  def void test(List<String> s) {
			  s.sort
			  }
			}
		''')
	}


	@Test def testImportedOperators_01() {
		'''
			import static extension test.StaticOperators.*
			class Foo {
			  def void test(String s) {
			    -s
			  }
			}
		'''.assertIsOrganizedTo('''
			import static extension test.StaticOperators.*

			class Foo {
			  def void test(String s) {
			    -s
			  }
			}
		''')
	}

	@Test def testImportedOperators_02() {
		'''
			import static extension test.StaticOperators.*
			class Foo {
			  def void test(String s) {
			    s-s
			  }
			}
		'''.assertIsOrganizedTo('''
			import static extension test.StaticOperators.*

			class Foo {
			  def void test(String s) {
			    s-s
			  }
			}
		''')
	}

	@Test def testImportedOperators_03() {
		'''
			import static extension test.StaticOperators.*
			class Foo {
			  def void test(String s) {
			    s.assign = s
			  }
			}
		'''.assertIsOrganizedTo('''
			import static extension test.StaticOperators.*

			class Foo {
			  def void test(String s) {
			    s.assign = s
			  }
			}
		''')
	}

	@Test def testImportedOperators_04() {
		'''
			import static extension test.StaticOperators.*
			class Foo {
			  def void test(String it) {
			    assign = it
			  }
			}
		'''.assertIsOrganizedTo('''
			import static extension test.StaticOperators.*

			class Foo {
			  def void test(String it) {
			    assign = it
			  }
			}
		''')
	}

	@Test def testImplicitExtensions() {
		'''
			class Foo {
			  def void test(java.util.List<String> s) {
			    s.head
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			class Foo {
			  def void test(List<String> s) {
			    s.head
			  }
			}
		''')
	}

	@Test def testStaticExtensions() {
		'''
			import static extension java.util.Collections.*
			class Foo {
			  def void test() {
			    typeof(java.util.Collections).singleton
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.Collections

			import static extension java.util.Collections.*

			class Foo {
			  def void test() {
			    typeof(Collections).singleton
			  }
			}
		''')
	}

	@Test def testInnerClassImport_01() {
		'''
			package foo.bar
			import java.util.Map$Entry
			class Foo {
			  def Entry test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.util.Map$Entry

			class Foo {
			  def Entry test() {
			    return null
			  }
			}
		''')
	}

	@Test def testInnerClassImport_02() {
		'''
			package foo.bar
			import java.util.Map
			class Foo {
			  def Map$Entry test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.util.Map

			class Foo {
			  def Map$Entry test() {
			    return null
			  }
			}
		''')
	}

	@Test def testInnerClassImport_03() {
		'''
			package foo.bar
			import java.util.Map$Entry
			class Foo {
			  def Map$Entry test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.util.Map

			class Foo {
			  def Map$Entry test() {
			    return null
			  }
			}
		''')
	}

	@Test def testInnerClassImport_04() {
		'''
			package foo.bar
			import org.eclipse.emf.ecore.resource.Resource
			class Foo {
			  def Resource$Factory$Descriptor test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def Resource$Factory$Descriptor test() {
			    return null
			  }
			}
		''')
	}

	@Test def testInnerClassImport_05() {
		'''
			package foo.bar
			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor
			class Foo {
			  def Resource$Factory$Descriptor test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import org.eclipse.emf.ecore.resource.Resource

			class Foo {
			  def Resource$Factory$Descriptor test() {
			    return null
			  }
			}
		''')
	}

	@Test def testInnerClassImport_06() {
		'''
			package foo.bar
			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor
			class Foo {
			  def Descriptor test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor

			class Foo {
			  def Descriptor test() {
			    return null
			  }
			}
		''')
	}

	@Test def testFunctionTypes_afterResolve() {
		'''
			package foo.bar
			import java.util.Map$Entry
			class Foo {
			  def (Entry)=>void test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.util.Map$Entry

			class Foo {
			  def (Entry)=>void test() {
			    return null
			  }
			}
		''')
	}

	@Test def testFunctionTypes_beforeResolve() {
		'''
			package foo.bar
			import java.util.Map$Entry
			class Foo {
			  def (Entry)=>void test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.util.Map$Entry

			class Foo {
			  def (Entry)=>void test() {
			    return null
			  }
			}
		''')
	}

	@Test def testImport_PairOf() {
		'''
			package foo.bar
			import static org.eclipse.xtext.xbase.lib.Pair.*
			class Foo {
			  def Object test() {
			    return of('', '')
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import static org.eclipse.xtext.xbase.lib.Pair.*

			class Foo {
			  def Object test() {
			    return of('', '')
			  }
			}
		''')

	}

	@Test def testArrayType() {
		'''
			package foo.bar
			import java.io.Serializable
			class Foo {
			  def Serializable[][] test() {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import java.io.Serializable

			class Foo {
			  def Serializable[][] test() {
			    return null
			  }
			}
		''')
	}

	@Test def testAnnotationWithSameName() {
		'''
			package foo.bar
			annotation Serializable {
			  Class<? extends java.io.Serializable> clazz
			}
		'''.assertIsOrganizedTo('''
			package foo.bar
			
			annotation Serializable {
			  Class<? extends java.io.Serializable> clazz
			}
		''')
	}

	@Test def testClassWithSameName() {
		'''
			package foo.bar
			class Serializable {
			  Class<? extends java.io.Serializable> clazz
			}
		'''.assertIsOrganizedTo('''
			package foo.bar
			
			class Serializable {
			  Class<? extends java.io.Serializable> clazz
			}
		''')
	}

	@Test def testStaticImport_IterableExtensions() {
		'''
			package foo.bar
			import static org.eclipse.xtext.xbase.lib.IterableExtensions.*
			class Foo {
			  def Object test() {
			    return filter(null, null)
			  }
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import static org.eclipse.xtext.xbase.lib.IterableExtensions.*

			class Foo {
			  def Object test() {
			    return filter(null, null)
			  }
			}
		''')
	}

	@Test def testPropertyAnnotation() {
		'''
			package foo.bar
			class Foo {
			  @Property int prop
			}
		'''.assertIsOrganizedTo('''
			package foo.bar
			
			class Foo {
			  @Property int prop
			}
		''')
	}

	@Test def testNestedAnnotation_01() {
		'''
			package foo.bar

			import org.eclipse.xtext.service.DispatchingProvider$Runtime

			@Runtime
			class Foo {
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import org.eclipse.xtext.service.DispatchingProvider$Runtime

			@Runtime
			class Foo {
			}
		''')
	}

	@Test def testNestedAnnotation_02() {
		'''
			package foo.bar

			import org.eclipse.xtext.service.DispatchingProvider$Runtime

			@DispatchingProvider$Runtime
			class Foo {
			}
		'''.assertIsOrganizedTo('''
			package foo.bar

			import org.eclipse.xtext.service.DispatchingProvider

			@DispatchingProvider$Runtime
			class Foo {
			}
		''')
	}

	@Test def testBug388933_01() {
		'''
			import static extension MyExtensionLib.*

			class MyExtensionLib {
			    def static func1 (String a, int b) {  }
			}
			class MyClient {
			    def sample (String it) { func1(47)  }
			}
		'''.assertIsOrganizedTo('''
			import static extension MyExtensionLib.*

			class MyExtensionLib {
			    def static func1 (String a, int b) {  }
			}
			class MyClient {
			    def sample (String it) { func1(47)  }
			}
		''')
	}

	@Test def testBug388933_02() {
		'''
			import static java.util.Arrays.*

			class C {
			    var x = asList
			}
		'''.assertIsOrganizedTo('''
			import static java.util.Arrays.*

			class C {
			    var x = asList
			}
		''')
	}

	@Test def testBug380637_01() {
		'''
			class MyExtensionLib {
			    def static func1 (String a, int b) {
			       func1(a,b)
			    }
			}
		'''.assertIsOrganizedTo('''
			class MyExtensionLib {
			    def static func1 (String a, int b) {
			       func1(a,b)
			    }
			}
		''')
	}

	@Test def testBug380637_02() {
		'''
			abstract class MyClass implements org.eclipse.xtext.scoping.IScope {
			    org.eclipse.xtext.scoping.IScope scope = NULLSCOPE
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.xtext.scoping.IScope

			abstract class MyClass implements IScope {
			    IScope scope = NULLSCOPE
			}
		''')
	}

	@Test def testBug380637_03() {
		'''
			abstract class MyClass extends org.eclipse.xtext.scoping.impl.AbstractScope {
			    new() {
			        super(null, false)
			    }
			    Object field = NULLSCOPE
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.xtext.scoping.impl.AbstractScope

			abstract class MyClass extends AbstractScope {
			    new() {
			        super(null, false)
			    }
			    Object field = NULLSCOPE
			}
		''')
	}

	@Test def testDontOverrideTypeParameter() {
		'''
			class Foo<String> {
				java.lang.String s
			}
		'''.assertIsOrganizedTo('''
			class Foo<String> {
				java.lang.String s
			}
		''')
	}
	
	@Test def testInheritedInnerClass() {
		'''
			class Foo extends types.OuterClass {
				types.OuterClass$MiddleClass foo
			}
		'''.assertIsOrganizedTo('''
			import types.OuterClass
			
			class Foo extends OuterClass {
				OuterClass$MiddleClass foo
			}
		''')
	}

	@Test def testDontOverrideInheritedInnerClass() {
		// 'OuterClass' has an inner class 'MiddleClass'
		// that cannot be shadowed by an import
		'''
			class Foo extends types.OuterClass {
				types.MiddleClass foo
			}
		'''.assertIsOrganizedTo('''
			import types.OuterClass
			
			class Foo extends OuterClass {
				types.MiddleClass foo
			}
		''')
	}
	
	@Test def testJavaDoc() {
		'''
			/**
			 * {@link java.util.List}
			 */
			class Foo {}
		'''.assertIsOrganizedTo('''
			import java.util.List
			
			/**
			 * {@link List}
			 */
			class Foo {}
		''')
	}
}