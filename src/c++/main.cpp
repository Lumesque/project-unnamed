/** @file
* This is an introduction into how doxygen comments will be generated.
*
*/
#include <iostream>

/** A test class with an example description */
/*! A more elaborate class description. */
class ExampleClass {
public:
    /** Class constructor
     *  Some form of a description
     */
    ExampleClass() = default;
    /** Class destructor
     *  Some form of a description
     */
    ~ExampleClass() = default;
    /** A normal member taking two arguments and returning an integer value. */
    /*!
     * @param a an integer value
     * @param s a constant character pointer
     * @return The test result
     * \sa ExampleClass(), ~ExampleClass()
     */
    int testMe(int a, const char *s) { return 0; };
};

int main(int argc /**< [in] docs for input parameter. */, const char** argv) {
    int x = 1; /**< Description of member variable */
    std::cout << x << " " << "Hello, world!\n";
    return 0;
}
