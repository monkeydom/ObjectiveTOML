//
//  LMP_cpptoml_visitors.h
//  tomlutil
//
//  Created by dom on 10/20/18.
//  Copyright © 2018 Lone Monkey Productions. All rights reserved.
//

#ifndef LMP_cpptoml_visitors_h
#define LMP_cpptoml_visitors_h

/**
 * A visitor for toml objects that writes to an output stream in the JSON
 * format that the toml-test suite expects.
 */
class toml_test_writer
{
public:
    toml_test_writer(std::ostream& s) : stream_(s)
    {
        // nothing
    }
    
    void visit(const cpptoml::value<std::string>& v)
    {
        stream_ << "{\"type\":\"string\",\"value\":\""
        << cpptoml::toml_writer::escape_string(v.get()) << "\"}";
    }
    
    void visit(const cpptoml::value<int64_t>& v)
    {
        stream_ << "{\"type\":\"integer\",\"value\":\"" << v.get() << "\"}";
    }
    
    void visit(const cpptoml::value<double>& v)
    {
        stream_ << "{\"type\":\"float\",\"value\":\"" << v.get() << "\"}";
    }
    
    void visit(const cpptoml::value<cpptoml::local_date>& v)
    {
        stream_ << "{\"type\":\"local_date\",\"value\":\"" << v.get() << "\"}";
    }
    
    void visit(const cpptoml::value<cpptoml::local_time>& v)
    {
        stream_ << "{\"type\":\"local_time\",\"value\":\"" << v.get() << "\"}";
    }
    
    void visit(const cpptoml::value<cpptoml::local_datetime>& v)
    {
        stream_ << "{\"type\":\"local_datetime\",\"value\":\"" << v.get()
        << "\"}";
    }
    
    void visit(const cpptoml::value<cpptoml::offset_datetime>& v)
    {
        stream_ << "{\"type\":\"datetime\",\"value\":\"" << v.get() << "\"}";
    }
    
    void visit(const cpptoml::value<bool>& v)
    {
        stream_ << "{\"type\":\"bool\",\"value\":\"" << v << "\"}";
    }
    
    void visit(const cpptoml::array& arr)
    {
        stream_ << "{\"type\":\"array\",\"value\":[";
        auto it = arr.get().begin();
        while (it != arr.get().end())
        {
            (*it)->accept(*this);
            if (++it != arr.get().end())
                stream_ << ", ";
        }
        stream_ << "]}";
    }
    
    void visit(const cpptoml::table_array& tarr)
    {
        stream_ << "[";
        auto arr = tarr.get();
        auto ait = arr.begin();
        while (ait != arr.end())
        {
            (*ait)->accept(*this);
            if (++ait != arr.end())
                stream_ << ", ";
        }
        stream_ << "]";
    }
    
    void visit(const cpptoml::table& t)
    {
        stream_ << "{";
        auto it = t.begin();
        while (it != t.end())
        {
            stream_ << '"' << cpptoml::toml_writer::escape_string(it->first)
            << "\":";
            it->second->accept(*this);
            if (++it != t.end())
                stream_ << ", ";
        }
        stream_ << "}";
    }
    
private:
    std::ostream& stream_;
};



/**
 * A visitor for toml objects that writes to an NSMutableDictionary
 */
class toml_nsdictionary_writer {
public:
    toml_nsdictionary_writer() {
        currentDictionary_ = resultContainer_ = [NSMutableDictionary new];
        currentKey_ = @"TOMLRoot";
    }

    NSDictionary *dictionary() {
        return [resultContainer_[@"TOMLRoot"] copy];
    }

    
    void visit(const cpptoml::value<std::string>& v) {
        id value = [NSString stringWithUTF8String:v.get().c_str()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<int64_t>& v) {
        id value = [NSNumber numberWithLongLong:v.get()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<double>& v) {
        id value = [NSNumber numberWithDouble:v.get()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<cpptoml::local_date>& v) {
        id value = ({
            cpptoml::local_date ld = v.get();
            NSDateComponents *result = [NSDateComponents new];
            result.year = ld.year;
            result.month = ld.month;
            result.day = ld.day;
            result;
        });
        writeValue(value);
    }
    
    void visit(const cpptoml::value<cpptoml::local_time>& v) {
        std::stringstream s("");
        s << v.get();
        id value = [NSString stringWithUTF8String:s.str().c_str()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<cpptoml::local_datetime>& v) {
        std::stringstream s("");
        s << v.get();
        id value = [NSString stringWithUTF8String:s.str().c_str()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<cpptoml::offset_datetime>& v) {
        std::stringstream s("");
        s << v.get();
        id value = [NSString stringWithUTF8String:s.str().c_str()];
        writeValue(value);
    }
    
    void visit(const cpptoml::value<bool>& v) {
        id value = v.get() ? @YES : @NO;
        writeValue(value);
    }
    
    void visit(const cpptoml::array& arr) {
        withContainerIsDictionary( NO, ^{
            for (auto it = arr.get().begin(); it != arr.get().end(); it++) {
                (*it)->accept(*this);
            }
        });
    }
    
    void visit(const cpptoml::table_array& tarr) {
        
        withContainerIsDictionary( NO, ^{
            auto arr = tarr.get();
            for (auto ait = arr.begin(); ait != arr.end(); ait++) {
                (*ait)->accept(*this);
            }
        });

    }
    
    void visit(const cpptoml::table& t) {
        withContainerIsDictionary( YES, ^{
            for (auto it = t.begin(); it != t.end(); it++) {
                currentKey_ = [NSString stringWithUTF8String:it->first.c_str()];
                it->second->accept(*this);
            }
        });
    }
    
private:

    void withContainerIsDictionary(BOOL isDictionary, dispatch_block_t stuff) {
        NSMutableArray *array = currentArray_;
        NSMutableDictionary *dict = currentDictionary_;
        NSString *key = currentKey_;

        if (isDictionary) {
            NSMutableDictionary *contextDictionary = [NSMutableDictionary new];
            writeValue(contextDictionary);
            
            currentDictionary_ = contextDictionary;
            currentArray_ = nil;
        } else {
            NSMutableArray *contextArray = [NSMutableArray new];
            writeValue(contextArray);
            
            currentArray_ = contextArray;
        }
        
        stuff();
        
        currentKey_ = key;
        currentArray_ = array;
        currentDictionary_ = dict;
    }
    
    void writeValue(id value) {
        if (currentArray_) {
            [currentArray_ addObject:value];
        } else {
            currentDictionary_[currentKey_] = value;
        }
    }
    
    NSMutableDictionary *resultContainer_;
    NSMutableDictionary *currentDictionary_;
    NSString *currentKey_;
    NSMutableArray *currentArray_;
};




#endif /* LMP_cpptoml_visitors_h */
